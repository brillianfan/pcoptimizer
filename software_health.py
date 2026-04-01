import subprocess
import shutil

def is_winget_installed():
    return shutil.which("winget") is not None

def get_upgradable_apps(log_callback=None):
    if not is_winget_installed():
        if log_callback: log_callback("[ERROR] Winget not found.")
        return []
        
    if log_callback: log_callback("[+] Checking for software updates...")
    try:
        # winget upgrade returns a table-like output
        result = subprocess.run(["winget", "upgrade", "--accept-source-agreements"], capture_output=True, text=True, check=False)
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
        process = subprocess.Popen(
            ["winget", "upgrade", "--all", "--accept-package-agreements", "--accept-source-agreements"],
            stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True, shell=True
        )
        if process.stdout:
            for line in process.stdout:
                if log_callback: log_callback(line.strip())
        process.wait()
        if log_callback: log_callback("[OK] Software upgrade completed.")
    except Exception as e:
        if log_callback: log_callback(f"[ERROR] Failed to upgrade: {e}")

def upgrade_app(app_id, log_callback=None):
    if log_callback: log_callback(f"[+] Upgrading {app_id}...")
    try:
        # Use --silent and --force if needed, but for now just basic upgrade
        subprocess.run(["winget", "upgrade", "--id", app_id, "--accept-package-agreements", "--accept-source-agreements"], check=True)
        if log_callback: log_callback(f"[OK] {app_id} updated.")
        return True
    except Exception as e:
        if log_callback: log_callback(f"[ERROR] Failed to upgrade {app_id}: {e}")
        return False

def get_upgradable_apps_list(log_callback=None):
    if not is_winget_installed():
        return []
    
    try:
        # Get output from winget upgrade
        result = subprocess.run(["winget", "upgrade", "--accept-source-agreements"], capture_output=True, text=True, check=False)
        lines = result.stdout.splitlines()
        
        apps = []
        parsing = False
        for line in lines:
            if not line.strip(): continue
            if "Name" in line and "Id" in line:
                parsing = True
                # Find column indices for better parsing
                header = line
                idx_id = header.find("Id")
                idx_ver = header.find("Version")
                idx_avail = header.find("Available")
                idx_source = header.find("Source")
                continue
            
            if parsing and not line.startswith("-") and not line.startswith("<"):
                # Use the indices found to split the line
                name = line[:idx_id].strip()
                app_id = line[idx_id:idx_ver].strip()
                version = line[idx_ver:idx_avail].strip()
                available = line[idx_avail:idx_source].strip()
                source = line[idx_source:].strip()
                
                if name and app_id:
                    apps.append({
                        "name": name,
                        "id": app_id,
                        "version": version,
                        "available": available,
                        "source": source
                    })
        
        return apps
    except Exception as e:
        if log_callback: log_callback(f"[ERROR] Winget error: {e}")
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
