import subprocess
import ctypes
import os

def is_admin():
    try:
        return ctypes.windll.shell32.IsUserAnAdmin()
    except:
        return False

def internet_boost(log_callback=None):
    if not is_admin():
        if log_callback: log_callback("[ERROR] Admin privileges required for Internet Boost.")
        return

    commands = [
        ('netsh int tcp set global autotuninglevel=normal', 'TCP Autotuning optimized'),
        ('netsh int tcp set global rss=enabled', 'RSS enabled'),
        ('netsh int tcp set global fastopen=enabled', 'TCP Fast Open enabled'),
        ('netsh interface tcp set global timestamps=disabled', 'TCP Timestamps disabled'),
        ('ipconfig /flushdns', 'DNS Cache flushed')
    ]
    
    if log_callback: log_callback("[+] Optimizing network settings...")
    
    success = 0
    for cmd, desc in commands:
        try:
            subprocess.run(cmd, shell=True, check=True, capture_output=True)
            if log_callback: log_callback(f"[OK] {desc}")
            success += 1
        except Exception as e:
            if log_callback: log_callback(f"[ERROR] Failed {desc}: {e}")
            
    if log_callback: log_callback(f"\n[DONE] Network optimization completed ({success}/{len(commands)}).")

def toggle_windows_update(enable=True, log_callback=None):
    if not is_admin():
        if log_callback: log_callback("[ERROR] Admin privileges required.")
        return

    state = "demand" if enable else "disabled"
    action = "enable" if enable else "disable"
    
    try:
        if log_callback: log_callback(f"[+] Setting Windows Update to {action}...")
        # Config service
        subprocess.run(f'sc config wuauserv start= {state}', shell=True, check=True, capture_output=True)
        
        # Start/Stop service
        if enable:
            subprocess.run('net start wuauserv', shell=True, capture_output=True)
        else:
            subprocess.run('net stop wuauserv /y', shell=True, capture_output=True)
            
        if log_callback: log_callback(f"[OK] Windows Update {action}dSuccessfully!")
    except Exception as e:
        if log_callback: log_callback(f"[ERROR] Failed to {action} Windows Update: {e}")

if __name__ == "__main__":
    def simple_log(msg): print(msg)
    if is_admin():
        internet_boost(simple_log)
    else:
        print("Please run as administrator.")
