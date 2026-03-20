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
        subprocess.run(["winget", "upgrade", "--id", app_id, "--accept-package-agreements"], check=True)
        if log_callback: log_callback(f"[OK] {app_id} updated.")
    except Exception as e:
        if log_callback: log_callback(f"[ERROR] Failed to upgrade {app_id}: {e}")

if __name__ == "__main__":
    def simple_log(msg): print(msg)
    if is_winget_installed():
        apps = get_upgradable_apps(simple_log)
        print(f"Found {len(apps)} updates.")
