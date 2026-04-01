# win32com and pythoncom imports moved inside functions for thread-safe COM initialization.
import ctypes
import subprocess

# Flag to suppress console window for background processes
CREATE_NO_WINDOW = 0x08000000

def is_admin():
    try:
        return ctypes.windll.shell32.IsUserAnAdmin() # type: ignore
    except:
        return False

def search_updates(log_callback=None):
    if log_callback: log_callback("[+] Calling Windows Update API...")
    import win32com.client # type: ignore
    import pythoncom # type: ignore
    
    try:
        # Initialize COM for the current thread
        pythoncom.CoInitialize()
        
        # Using Microsoft.Update.Session COM object
        session = win32com.client.Dispatch("Microsoft.Update.Session")
        searcher = session.CreateUpdateSearcher()
        if log_callback: log_callback("    Searching for driver updates...")
        
        # Search criteria for drivers
        result = searcher.Search("IsInstalled=0 and Type='Driver'")
        updates = result.Updates
        
        if log_callback: log_callback(f"    Found {updates.Count} available updates.")
        
        upd_list = []
        for i in range(updates.Count):
            upd = updates.Item(i)
            upd_list.append({"title": upd.Title, "id": i})
            
        return upd_list
    except Exception as e:
        if log_callback: log_callback(f"[ERROR] Update API error: {e}")
        return []
    finally:
        # Always uninitialize COM
        pythoncom.CoUninitialize()

def install_updates(log_callback=None):
    if not is_admin():
        if log_callback: log_callback("[ERROR] Admin privileges required.")
        return

    if log_callback: log_callback("[+] Starting Driver Installation via PowerShell...")
    try:
        # Complex COM interactions are safer in native PowerShell
        ps_cmd = """
        $ErrorActionPreference = 'Stop'
        try {
            Write-Host "Initializating Update Session..."
            $session = New-Object -ComObject Microsoft.Update.Session
            $searcher = $session.CreateUpdateSearcher()
            Write-Host "Searching for available drivers..."
            $result = $searcher.Search("IsInstalled=0 and Type='Driver'")
            
            if ($result.Updates.Count -eq 0) {
                Write-Host "No driver updates found."
                return
            }
            
            Write-Host "Found $($result.Updates.Count) driver updates. Downloading..."
            $downloader = $session.CreateUpdateDownloader()
            $downloader.Updates = $result.Updates
            $downloader.Download()
            
            Write-Host "Installing drivers..."
            $installer = $session.CreateUpdateInstaller()
            $installer.Updates = $result.Updates
            $installResult = $installer.Install()
            
            Write-Host "Installation completed with ResultCode: $($installResult.ResultCode)"
        } catch {
            Write-Host "Error: $($_.Exception.Message)"
            exit 1
        }
        """
        process = subprocess.Popen(
            ["powershell", "-NoProfile", "-ExecutionPolicy", "Bypass", "-Command", ps_cmd],
            stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True, creationflags=CREATE_NO_WINDOW
        )
        
        if process.stdout:
            for line in process.stdout: # type: ignore
                if log_callback: log_callback(f"PS: {line.strip()}")
            
        process.wait()
        if process.returncode == 0:
            if log_callback: log_callback("[OK] Driver update process finished.")
        else:
            if log_callback: log_callback("[ERROR] PowerShell script failed.")
            
    except Exception as e:
        if log_callback: log_callback(f"[ERROR] Driver update failed: {e}")

if __name__ == "__main__":
    def simple_log(msg): print(msg)
    if is_admin():
        search_updates(simple_log)
    else:
        print("Run as admin.")
