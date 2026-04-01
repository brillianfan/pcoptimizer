import winreg
import ctypes
import os

def is_admin():
    try:
        return ctypes.windll.shell32.IsUserAnAdmin()
    except:
        return False

def set_reg_value(hkey, subkey, name, value, type_str='String', log_callback=None):
    try:
        # Map hive strings
        hive = None
        if hkey == 'HKCU': hive = winreg.HKEY_CURRENT_USER
        elif hkey == 'HKLM': hive = winreg.HKEY_LOCAL_MACHINE
        
        if not hive: return False
        
        # Open or Create Key
        key = winreg.CreateKeyEx(hive, subkey, 0, winreg.KEY_SET_VALUE)
        
        # Set Value
        if type_str == 'String':
            winreg.SetValueEx(key, name, 0, winreg.REG_SZ, str(value))
        elif type_str == 'DWord':
            winreg.SetValueEx(key, name, 0, winreg.REG_DWORD, int(value))
        
        winreg.CloseKey(key)
        return True
    except Exception as e:
        if log_callback: log_callback(f"[ERROR] Registry Error: {e}")
        return False

def optimize_responsiveness(log_callback=None):
    if log_callback: log_callback("[+] Optimizing System Responsiveness...")
    
    opts = [
        {'hkey': 'HKCU', 'subkey': r'Control Panel\Desktop', 'name': 'WaitToKillAppTimeout', 'value': '2000', 'type': 'String', 'desc': 'Reduce app close timeout'},
        {'hkey': 'HKCU', 'subkey': r'Control Panel\Desktop', 'name': 'MenuShowDelay', 'value': '0', 'type': 'String', 'desc': 'Remove menu delay'},
        {'hkey': 'HKCU', 'subkey': r'Control Panel\Desktop', 'name': 'AutoEndTasks', 'value': '1', 'type': 'String', 'desc': 'Auto-close unresponsive apps'},
        {'hkey': 'HKCU', 'subkey': r'Control Panel\Mouse', 'name': 'MouseHoverTime', 'value': '10', 'type': 'String', 'desc': 'Increase mouse responsiveness'},
        {'hkey': 'HKLM', 'subkey': r'SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile', 'name': 'NetworkThrottlingIndex', 'value': 0xFFFFFFFF, 'type': 'DWord', 'desc': 'Optimize network throttling'},
        {'hkey': 'HKLM', 'subkey': r'SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile', 'name': 'SystemResponsiveness', 'value': 0, 'type': 'DWord', 'desc': 'Maximize system responsiveness'}
    ]
    
    success = 0
    for opt in opts:
        if set_reg_value(opt['hkey'], opt['subkey'], opt['name'], opt['value'], opt['type'], log_callback):
            if log_callback: log_callback(f"[OK] {opt['desc']}")
            success += 1
            
    if log_callback: log_callback(f"\n[DONE] Applied {success}/{len(opts)} optimizations.")

def backup_registry(log_callback=None):
    if log_callback: log_callback("[+] Creating Registry Backup on Desktop...")
    # This usually requires running 'reg export' for simplicity
    try:
        desktop = os.path.join(os.path.expanduser("~"), "Desktop")
        backup_file = os.path.join(desktop, "Registry_Backup.reg")
        # Export common keys
        keys = ['HKCU\\Control Panel\\Desktop', 'HKCU\\Control Panel\\Mouse']
        for key in keys:
            os.system(f'reg export "{key}" "{backup_file}" /y >nul 2>&1')
        
        if log_callback: log_callback(f"[OK] Backup created: {backup_file}")
        return True
    except Exception as e:
        if log_callback: log_callback(f"[ERROR] Backup failed: {e}")
        return False

if __name__ == "__main__":
    def simple_log(msg): print(msg)
    if is_admin():
        optimize_responsiveness(simple_log)
    else:
        print("Please run as administrator.")
