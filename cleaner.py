import os
import shutil
import ctypes
import platform
import subprocess

def is_admin():
    try:
        return ctypes.windll.shell32.IsUserAnAdmin() # type: ignore
    except:
        return False

def clean_folder(folder_path, log_callback=None):
    """Deletes all files and folders inside the given path."""
    if not os.path.exists(folder_path):
        if log_callback: log_callback(f"[SKIP] Path not found: {folder_path}")
        return

    if log_callback: log_callback(f"[+] Cleaning: {folder_path}...")
    
    files_deleted: int = 0
    errors: int = 0
    
    for item in os.listdir(folder_path):
        item_path = os.path.join(folder_path, item)
        try:
            if os.path.isfile(item_path) or os.path.islink(item_path):
                os.unlink(item_path)
                files_deleted += 1 # type: ignore
            elif os.path.isdir(item_path):
                shutil.rmtree(item_path)
                files_deleted += 1 # type: ignore
        except Exception as e:
            errors += 1 # type: ignore
            # In use common error
            pass
            
    if log_callback: 
        log_callback(f"[OK] Cleaned {files_deleted} items ({errors} items in use/skipped).")

def clean_temp_files(log_callback=None):
    # User Temp
    user_temp = os.environ.get('TEMP')
    if user_temp:
        clean_folder(user_temp, log_callback)
    
    # Windows Temp
    win_temp = os.path.join(os.environ.get('SystemRoot', 'C:\\Windows'), 'Temp')
    clean_folder(win_temp, log_callback)
    
    # Prefetch (Needs Admin)
    prefetch = os.path.join(os.environ.get('SystemRoot', 'C:\\Windows'), 'Prefetch')
    clean_folder(prefetch, log_callback)

def empty_recycle_bin(log_callback=None):
    if log_callback: log_callback("[+] Emptying Recycle Bin...")
    try:
        # SHEmptyRecycleBinW(HWND, RootPath, Flags)
        # Flags: SHERB_NOCONFIRMATION = 1, SHERB_NOPROGRESSUI = 2, SHERB_NOSOUND = 4
        ctypes.windll.shell32.SHEmptyRecycleBinW(None, None, 1 | 2 | 4) # type: ignore
        if log_callback: log_callback("[OK] Recycle Bin emptied!")
    except Exception as e:
        if log_callback: log_callback(f"[ERROR] Could not empty Recycle Bin: {e}")

def clear_system_logs(log_callback=None):
    if log_callback: log_callback("[+] Clearing System Event Logs...")
    if not is_admin():
        if log_callback: log_callback("[ERROR] Admin privileges required for clear_system_logs.")
        return

    try:
        # Optimized approach using PowerShell to filter logs that actually have records
        # This is much faster than looping through 1000+ logs sequentially in Python
        ps_command = (
            "Get-WinEvent -ListLog * -ErrorAction SilentlyContinue | "
            "Where-Object { $_.RecordCount -gt 0 } | "
            "ForEach-Object { wevtutil.exe cl $_.LogName 2>$null }"
        )
        
        subprocess.run(['powershell', '-Command', ps_command], check=True, capture_output=True)
        
        if log_callback: log_callback("[OK] System logs cleared efficiently.")
    except Exception as e:
        if log_callback: log_callback(f"[ERROR] Failed to clear logs: {e}")

def run_disk_cleanup(log_callback=None):
    if log_callback: log_callback("[+] Launching Windows Disk Cleanup...")
    try:
        # /verylowdisk runs with all options checked and handles it automatically (shows progress)
        # /d C: ensures it targets the primary OS drive
        # We use run() instead of Popen() so the GUI log accurately reflects when it finishes.
        subprocess.run(['cleanmgr', '/verylowdisk', '/d', 'C:'], check=False)
        if log_callback: log_callback("[OK] Windows Disk Cleanup completed.")
    except Exception as e:
        if log_callback: log_callback(f"[ERROR] Could not launch Disk Cleanup: {e}")

def remove_empty_folders(log_callback=None):
    if log_callback: log_callback("[+] Scanning for empty folders...")
    roots = [
        'C:\\ProgramData',
        os.environ.get('APPDATA'),
        os.environ.get('LOCALAPPDATA'),
        'C:\\Program Files',
        'C:\\Program Files (x86)'
    ]
    
    removed: int = 0
    for root in roots:
        if root and os.path.exists(root):
            if log_callback: log_callback(f"  Scanning: {root}")
            for dirpath, dirnames, filenames in os.walk(root, topdown=False):
                if not dirnames and not filenames:
                    try:
                        os.rmdir(dirpath)
                        removed += 1 # type: ignore
                    except:
                        pass
    if log_callback: log_callback(f"[OK] Removed {removed} empty folders.")

def remove_broken_shortcuts(log_callback=None):
    if log_callback: log_callback("[+] Removing broken shortcuts...")
    import win32com.client # type: ignore
    import pythoncom # type: ignore
    
    try:
        # Initialize COM for the current thread
        pythoncom.CoInitialize()
        shell = win32com.client.Dispatch("WScript.Shell")
    except Exception as e:
        if log_callback: log_callback(f"[ERROR] Could not initialize WScript.Shell: {e}")
        return
    
    try:
        # Expanded search paths for better coverage
        user_profile = os.environ.get('USERPROFILE', '')
        app_data = os.environ.get('APPDATA', '')
        program_data = os.environ.get('ProgramData', 'C:\\ProgramData')
        public_profile = os.environ.get('PUBLIC', 'C:\\Users\\Public')

        search_paths = [
            os.path.join(user_profile, "Desktop"),
            os.path.join(public_profile, "Desktop"),
            os.path.join(app_data, r"Microsoft\Windows\Start Menu\Programs"),
            os.path.join(program_data, r"Microsoft\Windows\Start Menu\Programs"),
            os.path.join(app_data, r"Microsoft\Internet Explorer\Quick Launch"),
            os.path.join(app_data, r"Microsoft\Internet Explorer\Quick Launch\User Pinned\TaskBar")
        ]
        
        count: int = 0
        for path in search_paths:
            if not path or not os.path.exists(path): continue
            if log_callback: log_callback(f"  Scanning: {path}")
            
            for root, dirs, files in os.walk(path):
                for file in files:
                    file_path = os.path.join(root, file)
                    target = None
                    
                    try:
                        if file.lower().endswith(".lnk"):
                            shortcut = shell.CreateShortcut(file_path)
                            target = shortcut.TargetPath
                        elif file.lower().endswith(".url"):
                            # Extract URL from .url file
                            with open(file_path, 'r', encoding='utf-8', errors='ignore') as f:
                                for line in f:
                                    if line.startswith("URL="):
                                        target = line.split("=", 1)[1].strip()
                                        break
                        
                        if target:
                            # Check if it's a local path (starts with drive letter like C: or network path \\)
                            is_local = (len(target) >= 2 and target[1] == ':' and target[0].isalpha()) or target.startswith("\\\\")
                            
                            if is_local:
                                if not os.path.exists(target):
                                    if log_callback: log_callback(f"  [X] Broken: {file} -> {target}")
                                    os.remove(file_path)
                                    count += 1 # type: ignore
                    except Exception:
                        continue
                        
        if log_callback: log_callback(f"[OK] Removed {count} broken shortcuts.")
    finally:
        # Always uninitialize COM
        pythoncom.CoUninitialize()

def manual_search_clean(app_name, log_callback=None):
    if not app_name or len(app_name) < 3:
        if log_callback: log_callback("[ERROR] Please enter a valid application name.")
        return

    if log_callback: log_callback(f"[+] Searching for: {app_name}...")
    
    locations = {
        "Program Files": "C:\\Program Files",
        "Program Files (x86)": "C:\\Program Files (x86)",
        "AppData": os.environ.get('APPDATA'),
        "Local AppData": os.environ.get('LOCALAPPDATA'),
        "ProgramData": "C:\\ProgramData"
    }
    
    found = []
    for name, path in locations.items():
        if path and os.path.exists(path):
            for item in os.listdir(path):
                if app_name.lower() in item.lower():
                    found.append(os.path.join(path, item))
                    
    if log_callback: log_callback(f"Found {len(found)} folders. Cleaning...")
    
    deleted: int = 0
    for path in found:
        try:
            if os.path.isdir(path):
                shutil.rmtree(path)
            else:
                os.remove(path)
            deleted += 1 # type: ignore
            if log_callback: log_callback(f" [X] Deleted: {path}")
        except:
            if log_callback: log_callback(f" [!] Failed: {path}")
            
    if log_callback: log_callback(f"[OK] Cleaned {deleted} items.")

if __name__ == "__main__":
    def simple_log(msg): print(msg)
    if is_admin():
        # Test new functions
        remove_empty_folders(simple_log)
        remove_broken_shortcuts(simple_log)
    else:
        print("Please run as administrator.")
