import winreg
import subprocess
import os
import ctypes
import json
import re
import tempfile
from PIL import Image

def get_store_apps():
    apps = []
    try:
        # Get removable non-framework store apps with InstallLocation, Logo, and Publisher
        cmd = 'powershell.exe -NoProfile -Command "Get-AppxPackage | Where-Object -Property NonRemovable -eq $False | Where-Object -Property IsFramework -eq $False | Select-Object Name, PackageFullName, InstallLocation, Logo, Publisher | ConvertTo-Json"'
        result = subprocess.run(cmd, capture_output=True, text=True, shell=True)
        if result.returncode == 0 and result.stdout.strip():
            data = json.loads(result.stdout)
            if isinstance(data, dict):
                data = [data]
            
            for item in data:
                apps.append({
                    "name": item.get("Name"),
                    "uninstall": item.get("PackageFullName"),
                    "install_location": item.get("InstallLocation"),
                    "logo": item.get("Logo"),
                    "publisher": item.get("Publisher"),
                    "is_store": True
                })
    except Exception as e:
        print(f"Error fetching Store apps: {e}")
    return apps

def get_installed_apps(app_type="all"):
    """
    app_type: "all", "store", or "desktop"
    """
    apps = []
    
    if app_type in ["all", "desktop"]:
        # Regular desktop apps from Registry
        keys = [
            (winreg.HKEY_LOCAL_MACHINE, r"SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall", winreg.KEY_READ | winreg.KEY_WOW64_64KEY),
            (winreg.HKEY_LOCAL_MACHINE, r"SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall", winreg.KEY_READ | winreg.KEY_WOW64_32KEY),
            (winreg.HKEY_CURRENT_USER, r"Software\Microsoft\Windows\CurrentVersion\Uninstall", winreg.KEY_READ)
        ]
        
        for hive, path, access in keys:
            try:
                key = winreg.OpenKey(hive, path, 0, access)
                for i in range(winreg.QueryInfoKey(key)[0]):
                    try:
                        subkey_name = winreg.EnumKey(key, i)
                        subkey = winreg.OpenKey(key, subkey_name)
                        
                        try:
                            name, _ = winreg.QueryValueEx(subkey, "DisplayName")
                        except:
                            name = ""
                            
                        try:
                            u_string, _ = winreg.QueryValueEx(subkey, "UninstallString")
                        except:
                            u_string = ""
                            
                        try:
                            icon_path, _ = winreg.QueryValueEx(subkey, "DisplayIcon")
                        except:
                            icon_path = ""
                            
                        try:
                            publisher, _ = winreg.QueryValueEx(subkey, "Publisher")
                        except:
                            publisher = ""
                            
                        if name and u_string:
                            apps.append({
                                "name": name,
                                "uninstall": u_string,
                                "icon_path": icon_path,
                                "publisher": publisher,
                                "is_store": False,
                                "subkey": subkey_name
                            })
                        winreg.CloseKey(subkey)
                    except:
                        pass
                winreg.CloseKey(key)
            except:
                pass
                
    if app_type in ["all", "store"]:
        # Add Store apps
        apps.extend(get_store_apps())
            
    # Deduplicate by name
    unique_apps = {a['name']: a for a in apps}.values()
    return sorted(list(unique_apps), key=lambda x: x['name'])

def run_uninstall(app_obj, log_callback=None):
    if not app_obj.get('uninstall'):
        if log_callback: log_callback("[ERROR] No uninstall string available.")
        return False
        
    if log_callback: log_callback(f"[+] Uninstalling {app_obj['name']}...")
    try:
        if app_obj.get('is_store'):
            # Store apps are removed via PowerShell
            package_name = app_obj['uninstall']
            cmd = f'powershell.exe -NoProfile -Command "Remove-AppxPackage -Package {package_name}"'
            result = subprocess.run(cmd, shell=True, capture_output=True, text=True)
            if result.returncode == 0:
                if log_callback: log_callback("[OK] Store app removed successfully.")
                # For Store apps, we can immediately scan leftovers
                remove_leftovers(app_obj['name'], log_callback)
            else:
                if log_callback: log_callback(f"[ERROR] Store app removal failed: {result.stderr}")
        else:
            # Traditional uninstaller execution
            cmd = app_obj['uninstall']
            # Try to handle quotes in the command
            if log_callback: log_callback(f"[+] Launching uninstaller: {cmd}")
            proc = subprocess.Popen(cmd, shell=True)
            if log_callback: log_callback("[OK] Uninstaller window launched. Please complete the uninstallation in the window.")
            
            # We can't easily wait for GUI uninstallers without blocking or periodic checking
            # But we can tell the user we're ready for leftovers
            if log_callback: log_callback("[INFO] Once finished, you can run a leftover scan.")
            
        return True
    except Exception as e:
        if log_callback: log_callback(f"[ERROR] Failed to run uninstaller: {e}")
        return False

def remove_leftovers(app_name, log_callback=None):
    if not app_name or len(app_name) < 3: return
    
    if log_callback: log_callback(f"[+] Scanning for leftovers: {app_name}...")
    
    # 1. SCAN DIRECTORIES
    # Generate search terms (ignore short words)
    import re
    search_terms = re.findall(r'\w+', app_name)
    search_terms = [t.lower() for t in search_terms if len(t) > 3]
    if not search_terms:
        search_terms = [app_name.lower()]

    # Define requested locations
    user_profile = os.environ.get('USERPROFILE', '')
    appdata = os.environ.get('APPDATA', '')
    local_appdata = os.environ.get('LOCALAPPDATA', '')
    program_data = os.environ.get('ProgramData', 'C:\\ProgramData')
    
    search_locations = {
        "Program Files": os.environ.get('ProgramFiles', 'C:\\Program Files'),
        "Program Files (x86)": os.environ.get('ProgramFiles(x86)', 'C:\\Program Files (x86)'),
        "AppData Roaming": appdata,
        "AppData Local": local_appdata,
        "AppData LocalLow": os.path.join(user_profile, 'AppData', 'LocalLow'),
        "ProgramData": program_data,
        "User Documents": os.path.join(user_profile, 'Documents'),
        "Desktop": os.path.join(user_profile, 'Desktop'),
        "Start Menu": os.path.join(appdata, 'Microsoft\\Windows\\Start Menu\\Programs'),
        "Common Start Menu": os.path.join(program_data, 'Microsoft\\Windows\\Start Menu\\Programs'),
        "Temp": os.environ.get('TEMP', '')
    }

    found_dirs = []
    import shutil

    for loc_name, path in search_locations.items():
        if not path or not os.path.exists(path):
            continue
            
        try:
            # Check for direct match or subfolders matching keywords
            items = os.listdir(path)
            for item in items:
                item_path = os.path.join(path, item)
                if not os.path.isdir(item_path):
                    continue
                    
                # Safety check: Avoid system/critical folders
                if item.lower() in ['windows', 'system32', 'users', 'microsoft']:
                    continue

                item_lower = item.lower()
                is_match = False
                
                # Check if app name is in item name
                if app_name.lower() in item_lower:
                    is_match = True
                else:
                    # Check if any non-trivial search term matches
                    for term in search_terms:
                        if term in item_lower:
                            is_match = True
                            break
                
                if is_match:
                    found_dirs.append(item_path)
        except Exception as e:
            pass
            
    # Deduplicate and remove
    found_dirs = list(set(found_dirs))
    for d in found_dirs:
        try:
            # Double check it's not a root search location itself
            if d in search_locations.values():
                continue
                
            shutil.rmtree(d, ignore_errors=True)
            if log_callback: log_callback(f" [X] Deleted folder: {d}")
        except:
            pass

    # 2. SCAN REGISTRY
    reg_paths = [
        (winreg.HKEY_CURRENT_USER, r"Software"),
        (winreg.HKEY_LOCAL_MACHINE, r"SOFTWARE"),
        (winreg.HKEY_LOCAL_MACHINE, r"SOFTWARE\WOW6432Node")
    ]
    
    for hive, path in reg_paths:
        try:
            key = winreg.OpenKey(hive, path, 0, winreg.KEY_ALL_ACCESS)
            # Try exact match first
            try:
                winreg.DeleteKey(key, app_name)
                if log_callback: log_callback(f" [X] Deleted Registry Key: {app_name}")
            except:
                # Try search terms in subkeys
                try:
                    for i in range(winreg.QueryInfoKey(key)[0]):
                        subkey_name = winreg.EnumKey(key, i)
                        if any(term in subkey_name.lower() for term in search_terms):
                            # Safety check: Avoid common high-level keys
                            if subkey_name.lower() not in ['microsoft', 'windows', 'classes', 'clients']:
                                # winreg.DeleteKey normally doesn't delete keys with subkeys
                                # We would need a recursive delete but that's risky. 
                                # For now, just attempt a direct delete of simple keys.
                                try:
                                    winreg.DeleteKey(key, subkey_name)
                                    if log_callback: log_callback(f" [X] Deleted Registry Key: {subkey_name}")
                                except: pass
                except: pass
            winreg.CloseKey(key)
        except:
            pass

    if log_callback: log_callback("[OK] Leftover scan completed.")

def get_app_icon(app_obj, size=32):
    """Returns a PIL Image object for the app icon."""
    try:
        icon_path = app_obj.get('icon_path', '')
        
        # 1. SPECIAL CASE: MSI Icons
        # Often DisplayIcon is just a path to an EXE or ICO
        # But it can also be a path with an index like "path,0"
        
        target_path = ""
        icon_index = 0
        
        if not app_obj.get('is_store'):
            if icon_path:
                if ',' in icon_path:
                    parts = icon_path.split(',')
                    target_path = parts[0].strip('" ')
                    try:
                        icon_index = int(parts[1])
                    except:
                        icon_index = 0
                else:
                    target_path = icon_path.strip('" ')
            
            # Fallback to UninstallString if it's an EXE
            if not target_path or not os.path.exists(target_path):
                u_string = app_obj.get('uninstall', '')
                match = re.search(r'([a-zA-Z]:\\[^:]+\.exe)', u_string, re.I)
                if match:
                    target_path = match.group(1)
        
        # 2. STORE APPS
        else:
            logo_path = app_obj.get('logo', '')
            install_loc = app_obj.get('install_location', '')
            
            if install_loc and os.path.exists(install_loc):
                # Potential logo candidates
                candidates = []
                if logo_path:
                    # Remove 'ms-appx:///' prefix if it exists
                    logo_path = logo_path.replace('ms-appx:///', '')
                    candidates.append(os.path.join(install_loc, logo_path))
                    # Handle scale factor variations (Windows Store apps use .scale-100, .scale-200 etc)
                    if '.' in logo_path:
                        name_part, ext_part = os.path.rsplit(logo_path, '.', 1)
                        candidates.append(os.path.join(install_loc, f"{name_part}.scale-100.{ext_part}"))
                        candidates.append(os.path.join(install_loc, f"{name_part}.scale-200.{ext_part}"))
                
                # Check candidates
                for cand in candidates:
                    if os.path.exists(cand):
                        return Image.open(cand).convert("RGBA").resize((size, size))
                
                # Try finding any png in Assets or root that looks like a logo
                search_dirs = [install_loc, os.path.join(install_loc, 'Assets'), os.path.join(install_loc, 'images')]
                for s_dir in search_dirs:
                    if os.path.exists(s_dir):
                        try:
                            files = os.listdir(s_dir)
                            # Sort by priority: contains "logo", "square", then any png
                            logo_files = [f for f in files if 'logo' in f.lower() and f.lower().endswith('.png')]
                            square_files = [f for f in files if 'square' in f.lower() and f.lower().endswith('.png')]
                            all_pngs = [f for f in files if f.lower().endswith('.png')]
                            
                            for f in (logo_files + square_files + all_pngs):
                                f_path = os.path.join(s_dir, f)
                                if os.path.isfile(f_path) and os.path.getsize(f_path) > 100: # Ignore tiny icons
                                    return Image.open(f_path).convert("RGBA").resize((size, size))
                        except:
                            pass
        
        # 3. EXTRACTION via PowerShell for Desktop apps
        if target_path and os.path.exists(target_path):
            temp_file = os.path.join(tempfile.gettempdir(), f"pc_opt_icon_{os.getpid()}.png")
            
            # Clean up old temp file
            if os.path.exists(temp_file): os.remove(temp_file)
            
            ps_cmd = f"Add-Type -AssemblyName System.Drawing; "
            # Handle index if possible, otherwise ExtractAssociatedIcon only gets the first one
            ps_cmd += f"[System.Drawing.Icon]::ExtractAssociatedIcon('{target_path}').ToBitmap().Save('{temp_file}', [System.Drawing.Imaging.ImageFormat]::Png)"
            
            subprocess.run(["powershell.exe", "-NoProfile", "-Command", ps_cmd], 
                           capture_output=True, text=True)
            
            if os.path.exists(temp_file):
                img = Image.open(temp_file).convert("RGBA").resize((size, size))
                os.remove(temp_file)
                return img
                
    except Exception as e:
        print(f"Icon extraction error for {app_obj.get('name')}: {e}")
        
    return None

