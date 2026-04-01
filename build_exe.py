import subprocess
import sys
import os

def build():
    print("Preparing to build PC Ultimate Optimizer EXE...")
    
    try:
        import PyInstaller.__main__
    except ImportError:
        print("PyInstaller not found. Installing...")
        subprocess.check_call([sys.executable, "-m", "pip", "install", "pyinstaller"])
        import PyInstaller.__main__

    # PyInstaller arguments
    # --onefile: Create a single executable
    # --noconsole: Don't show terminal window (it's a GUI app)
    # --clean: Clean cache
    # --name: Name of the output file
    # --additional-hooks-dir: CustomTkinter sometimes needs extra help
    
    # We need to include customtkinter assets if it doesn't do it automatically
    # For CustomTkinter, it's often better to include the theme json if used, 
    # but here we use the default themes.
    
    params = [
        'main_gui.py',
        '--onefile',
        '--noconsole',
        '--name=PC_Ultimate_Optimizer',
        '--clean',
        '--collect-all=customtkinter',
        '--hidden-import=psutil',
        '--hidden-import=wmi',
        '--hidden-import=pywin32',
        '--hidden-import=software_health',
        '--hidden-import=driver_update',
        '--icon=pc_opt_icon.ico',
        '--add-data=pc_opt_icon.ico;.',
        '--add-data=Deep-JunkClean.ps1;.',
        '--add-data=Driver-Update.ps1;.',
        '--add-data=Optimize-Registry.ps1;.',
        '--add-data=Remove-BrokenShortcuts.ps1;.',
        '--add-data=SearchAndClean.ps1;.',
    ]
    
    print(f"Running PyInstaller with: {' '.join(params)}")
    import PyInstaller.__main__
    PyInstaller.__main__.run(params)
    
    # Cleanup
    print("\n[+] Cleaning up build files...")
    import shutil
    try:
        if os.path.exists("build"):
            shutil.rmtree("build")
            print(" - Removed 'build' folder.")
        
        spec_file = "PC_Ultimate_Optimizer.spec"
        if os.path.exists(spec_file):
            os.remove(spec_file)
            print(f" - Removed '{spec_file}'")
    except Exception as e:
        print(f" - Warning: Cleanup failed: {e}")

    print("\n[SUCCESS] Build process finished!")
    print("Check the 'dist' folder for your PC_Ultimate_Optimizer.exe")

if __name__ == "__main__":
    build()
