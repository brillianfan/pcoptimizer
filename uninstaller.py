import winreg
import subprocess
import os
import ctypes
import json

def get_store_apps():
    apps = []
    try:
        # Get removable non-framework store apps
        cmd = 'powershell.exe -NoProfile -Command "Get-AppxPackage | Where-Object -Property NonRemovable -eq $False | Where-Object -Property IsFramework -eq $False | Select-Object Name, PackageFullName | ConvertTo-Json"'
        result = subprocess.run(cmd, capture_output=True, text=True, shell=True)
        if result.returncode == 0 and result.stdout.strip():
            # Handle both single object and list of objects
            data = json.loads(result.stdout)
            if isinstance(data, dict):
                data = [data]
            
            for item in data:
                apps.append({
                    "name": item.get("Name"),
                    "uninstall": item.get("PackageFullName"),
                    "is_store": True
                })
    except Exception as e:
        print(f"Error fetching Store apps: {e}")
    return apps

def get_installed_apps():
    apps = []
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
                        
                    if name and u_string:
                        apps.append({
                            "name": name,
                            "uninstall": u_string,
                            "is_store": False
                        })
                    winreg.CloseKey(subkey)
                except:
                    pass
            winreg.CloseKey(key)
        except:
            pass
            
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
            subprocess.Popen(cmd, shell=True)
            if log_callback: log_callback("[OK] Store app removal initiated.")
        else:
            # Traditional uninstaller execution
            import shlex
            cmd = app_obj['uninstall']
            subprocess.Popen(cmd, shell=True)
            if log_callback: log_callback("[OK] Uninstaller window launched.")
        return True
    except Exception as e:
        if log_callback: log_callback(f"[ERROR] Failed to run uninstaller: {e}")
        return False

def remove_leftovers(app_name, log_callback=None):
    if not app_name or len(app_name) < 3: return
    
    if log_callback: log_callback(f"[+] Scanning for leftovers: {app_name}...")
    
    # Files
    dirs = [os.environ.get('APPDATA'), os.environ.get('LOCALAPPDATA'), 'C:\\ProgramData']
    found_dirs = []
    for d in dirs:
        if not d: continue
        try:
            for item in os.listdir(d):
                if app_name.lower() in item.lower():
                    found_dirs.append(os.path.join(d, item))
        except: pass
        
    for d in found_dirs:
        try:
            import shutil
            shutil.rmtree(d)
            if log_callback: log_callback(f" [X] Deleted folder: {d}")
        except: pass

    # Registry
    reg_paths = [
        (winreg.HKEY_CURRENT_USER, r"Software"),
        (winreg.HKEY_LOCAL_MACHINE, r"SOFTWARE"),
        (winreg.HKEY_LOCAL_MACHINE, r"SOFTWARE\WOW6432Node")
    ]
    
    for hive, path in reg_paths:
        try:
            key = winreg.OpenKey(hive, path, 0, winreg.KEY_ALL_ACCESS)
            # This is complex to recurse, just try a direct match for the name
            try:
                winreg.DeleteKey(key, app_name)
                if log_callback: log_callback(f" [X] Deleted Registry Key: {app_name}")
            except: pass
            winreg.CloseKey(key)
        except: pass

    if log_callback: log_callback("[OK] Leftover scan completed.")

