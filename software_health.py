import subprocess
import shutil
import os

# Flag to suppress console window for background processes
CREATE_NO_WINDOW = 0x08000000

def is_winget_installed():
    return shutil.which("winget") is not None

def get_upgradable_apps(log_callback=None):
    if not is_winget_installed():
        if log_callback: log_callback("[ERROR] Winget not found.")
        return []
        
    if log_callback: log_callback("[+] Checking for software updates...")
    try:
        # winget upgrade returns a table-like output
        result = subprocess.run(["winget", "upgrade", "--accept-source-agreements"], 
                               capture_output=True, text=True, check=False, creationflags=CREATE_NO_WINDOW)
        lines = result.stdout.splitlines()
        
        apps = []
        parsing = False
        for line in lines:
            if not line.strip(): continue
            if "Name" in line and "Id" in line:
                parsing = True
                continue
            if parsing and not line.startswith("-") and not line.startswith("<"):
                # Heuristic: winget lines mostly have Name, Id, Version, Available...
                # We'll just log the line as is for the user to see progress
                if log_callback: log_callback(f" FOUND: {line.strip()}")
                apps.append(line)
        
        if not apps:
            if log_callback: log_callback("[INFO] No updates available or error fetching list.")
        else:
            if log_callback: log_callback(f"[OK] Found {len(apps)} items with available updates.")
            
        return apps
    except Exception as e:
        if log_callback: log_callback(f"[ERROR] Winget error: {e}")
        return []

def upgrade_all(log_callback=None):
    if log_callback: log_callback("[+] Upgrading all apps via Winget...")
    try:
        # Added --silent and --force for better background execution
        process = subprocess.Popen(
            "winget upgrade --all --silent --force --accept-package-agreements --accept-source-agreements",
            stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True, shell=True, creationflags=CREATE_NO_WINDOW,
            encoding='utf-8', errors='replace'
        )
        if process.stdout:
            for line in process.stdout:
                if log_callback: log_callback(line.strip())
        process.wait()
        if log_callback: log_callback("[OK] Software upgrade completed.")
    except Exception as e:
        if log_callback: log_callback(f"[ERROR] Failed to upgrade: {e}")

def upgrade_app(app_id, log_callback=None):
    app_id = str(app_id).strip()
    if log_callback: log_callback(f"[+] Upgrading package: {app_id}...")
    try:
        # Using --exact with --id is usually more reliable
        # Use Popen to feed the log callback line by line in real-time
        cmd = f'winget upgrade --id "{app_id}" --exact --silent --force --include-unknown --accept-package-agreements --accept-source-agreements'
        process = subprocess.Popen(
            cmd,
            stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True, shell=True, creationflags=CREATE_NO_WINDOW,
            encoding='utf-8', errors='replace'
        )
        
        if process.stdout:
            for line in process.stdout:
                if line.strip() and log_callback:
                    log_callback(line.strip())
        
        process.wait()
        
        if process.returncode == 0:
            if log_callback: log_callback(f"[OK] {app_id} updated.")
            return True
        else:
            # Some winget error codes are actually 'success but reboot needed' or 'no change'
            # But here we'll just log the return code for debugging
            if log_callback: log_callback(f"[INFO] Winget finished with code: {process.returncode}")
            # If it's a known success code (like 0x0), return True
            return process.returncode == 0
            
    except Exception as e:
        if log_callback: log_callback(f"[ERROR] Failed to upgrade {app_id}: {e}")
        return False


def get_upgradable_apps_list(log_callback=None):
    if not is_winget_installed():
        return []
    
    try:
        # Get output from winget upgrade
        result = subprocess.run("winget upgrade --accept-source-agreements", 
                               shell=True, capture_output=True, text=True, check=False, creationflags=CREATE_NO_WINDOW,
                               encoding='utf-8', errors='replace')
        lines = result.stdout.splitlines()
        
        apps = []
        parsing = False
        idx_id, idx_ver, idx_avail, idx_source = -1, -1, -1, -1
        header_offset = 0
        
        for line in lines:
            if not line.strip(): continue
            
            # More robust header detection (handles garbage characters at start)
            if "Name" in line and "Id" in line and ("Version" in line or "Available" in line):
                parsing = True
                # Find the start of the "Name" column to use as offset
                header_offset = line.find("Name")
                # Record relative positions of other columns based on the header
                idx_id = line.find("Id") - header_offset
                idx_ver = line.find("Version") - header_offset
                idx_avail = line.find("Available") - header_offset
                idx_source = line.find("Source") - header_offset
                continue
            
            # Skip separator lines and summary lines
            if parsing:
                if line.startswith("-") or line.startswith("<") or "upgrades available" in line:
                    continue
                
                # Check if this line is part of a previous message or garbage
                if len(line) < header_offset + idx_id:
                    continue

                try:
                    # Clean the line by removing any leading garbage matching header offset
                    clean_line = line[header_offset:]
                    
                    # Use the relative indices to split the clean line
                    name = clean_line[:idx_id].strip()
                    app_id = clean_line[idx_id:idx_ver].strip() if idx_ver > idx_id else clean_line[idx_id:].split()[0]
                    
                    # Handle version/available/source safely
                    version = ""
                    if idx_ver != -1:
                        end_ver = idx_avail if idx_avail > idx_ver else len(clean_line)
                        version = clean_line[idx_ver:end_ver].strip()
                        
                    available = ""
                    if idx_avail != -1:
                        end_avail = idx_source if idx_source > idx_avail else len(clean_line)
                        available = clean_line[idx_avail:end_avail].strip()
                        
                    source = ""
                    if idx_source != -1:
                        source = clean_line[idx_source:].strip()
                    
                    if name and app_id and app_id.lower() != "id":
                        apps.append({
                            "name": name,
                            "id": app_id,
                            "version": version,
                            "available": available,
                            "source": source
                        })
                except Exception as e:
                    # Skip problematic lines
                    continue
        
        return apps
    except Exception as e:
        if log_callback: log_callback(f"[ERROR] Winget parsing error: {e}")
        return []

def enrich_app_data(winget_apps, installed_apps):
    """
    Merges winget update info with installed app info (Publisher, Icon).
    """
    enriched = []
    for w_app in winget_apps:
        match = None
        # Try to find a match by subkey (exact ID)
        for i_app in installed_apps:
            if i_app.get('subkey') == w_app['id']:
                match = i_app
                break
        
        # If no subkey match, try name match
        if not match:
            for i_app in installed_apps:
                if i_app['name'].lower() == w_app['name'].lower():
                    match = i_app
                    break
        
        if match:
            w_app['publisher'] = match.get('publisher', 'Unknown Publisher')
            w_app['icon_path'] = match.get('icon_path', '')
            w_app['logo'] = match.get('logo', '')
            w_app['install_location'] = match.get('install_location', '')
            w_app['is_store'] = match.get('is_store', False)
        else:
            w_app['publisher'] = "Unknown Publisher"
            w_app['icon_path'] = ""
            w_app['is_store'] = False
            
        enriched.append(w_app)
    return enriched

if __name__ == "__main__":
    def simple_log(msg): print(msg)
    if is_winget_installed():
        apps = get_upgradable_apps(simple_log)
        print(f"Found {len(apps)} updates.")
