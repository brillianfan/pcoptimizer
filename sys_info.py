import wmi # type: ignore
import pythoncom # type: ignore
import platform
import psutil # type: ignore
import ctypes
import subprocess

def get_pc_specs():
    import pythoncom # type: ignore
    import wmi # type: ignore
    try:
        pythoncom.CoInitialize()
        c = wmi.WMI()
        specs: dict[str, any] = {} # type: ignore
        
        # OS
        os_info = c.Win32_OperatingSystem()[0]
        specs['os'] = os_info.Caption
        
        # CPU
        cpu_info = c.Win32_Processor()[0]
        specs['cpu'] = cpu_info.Name
        
        # RAM
        ram_raw = psutil.virtual_memory().total
        specs['ram'] = f"{round(ram_raw / (1024**3))} GB"
        
        # GPU
        gpus = c.Win32_VideoController()
        specs['gpus'] = [g.Name for g in gpus] # type: ignore
        
        # Storage
        disks = c.Win32_DiskDrive()
        specs['storage'] = [f"{d.Model} ({round(int(d.Size) / (1024**3))} GB)" for d in disks] # type: ignore
        
        return specs
    finally:
        pythoncom.CoUninitialize()

def get_windows_license():
    try:
        output = subprocess.check_output(['cscript', '//nologo', 'C:\\Windows\\System32\\slmgr.vbs', '/xpr'], text=True)
        return output.strip()
    except:
        return "Unknown"

def get_office_info():
    try:
        # PowerShell command from the original bat file to find Office name
        ps_cmd = "$office = Get-ItemProperty -Path 'HKLM:\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\*', 'HKLM:\\SOFTWARE\\WOW6432Node\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\*', 'HKCU:\\Software\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\*' -ErrorAction SilentlyContinue | Where-Object { ($_.DisplayName -like '*Microsoft Office*') -and ($_.DisplayName -notlike '*Update*') -and ($_.DisplayName -notlike '*MUI*') -and ($_.DisplayName -notlike '*Language Pack*') } | Select-Object -First 1; if ($office) { $office.DisplayName } else { 'Not found' }"
        output = subprocess.check_output(['powershell', '-Command', ps_cmd], text=True)
        return output.strip()
    except:
        return "Not found"

def get_office_license():
    try:
        # Find ospp.vbs and run /dstatus
        ps_cmd = "$ospp = Get-ChildItem -Path 'C:\\Program Files\\Microsoft Office', 'C:\\Program Files (x86)\\Microsoft Office' -Filter 'ospp.vbs' -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1; if ($ospp) { $status = cscript //nologo \"$($ospp.FullName)\" /dstatus; $status | Select-String 'LICENSE NAME', 'LICENSE STATUS' | ForEach-Object { $_.ToString().Trim() } } else { 'Office license info not found.' }"
        output = subprocess.check_output(['powershell', '-Command', ps_cmd], text=True)
        return output.strip() if output.strip() else "License info missing"
    except:
        return "Unknown"

def get_full_license_status():
    win = get_windows_license()
    off_name = get_office_info()
    off_lic = get_office_license()
    
    return {
        "windows": win,
        "office_name": off_name,
        "office_license": off_lic
    }

if __name__ == "__main__":
    print(get_pc_specs())
    print(get_full_license_status())
