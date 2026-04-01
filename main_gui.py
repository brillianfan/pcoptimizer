import tkinter as tk
import customtkinter as ctk # type: ignore
import sys
import os
import threading
import ctypes
from PIL import Image
from pathlib import Path

# Import our modules
import cleaner # type: ignore
import registry_opt # type: ignore
import uninstaller # type: ignore
import sys_info # type: ignore
import network_opt # type: ignore
import software_health # type: ignore
import driver_update # type: ignore

# Set appearance
ctk.set_appearance_mode("Dark")
ctk.set_default_color_theme("blue")

class PCOptimizerApp(ctk.CTk):
    def __init__(self):
        super().__init__()

        self.title("PC Ultimate Optimizer v2.1.0")
        self.geometry("1000x650")

        # Set App Icon
        self.setup_icon()

        # Check Admin
        self.is_admin = self.check_admin()

        # Grid layout (1x2)
        self.grid_rowconfigure(0, weight=1)
        self.grid_columnconfigure(1, weight=1)

        # Create navigation frame
        self.navigation_frame = ctk.CTkFrame(self, corner_radius=0)
        self.navigation_frame.grid(row=0, column=0, sticky="nsew")
        self.navigation_frame.grid_rowconfigure(4, weight=1)

        self.navigation_frame_label = ctk.CTkLabel(self.navigation_frame, text="🚀 PC Optimizer",
                                                 font=ctk.CTkFont(size=22, weight="bold"))
        self.navigation_frame_label.grid(row=0, column=0, padx=20, pady=25)

        self.home_button = ctk.CTkButton(self.navigation_frame, corner_radius=0, height=40, border_spacing=10, text="📊 Dashboard",
                                         fg_color="transparent", text_color=("gray10", "gray90"), hover_color=("gray70", "gray30"),
                                         anchor="w", command=self.home_button_event)
        self.home_button.grid(row=1, column=0, sticky="ew")

        self.cleaner_button = ctk.CTkButton(self.navigation_frame, corner_radius=0, height=40, border_spacing=10, text="🧹 Deep Clean",
                                            fg_color="transparent", text_color=("gray10", "gray90"), hover_color=("gray70", "gray30"),
                                            anchor="w", command=self.frame_cleaner_event)
        self.cleaner_button.grid(row=2, column=0, sticky="ew")

        self.tools_button = ctk.CTkButton(self.navigation_frame, corner_radius=0, height=40, border_spacing=10, text="🔧 Tools & Optimization",
                                         fg_color="transparent", text_color=("gray10", "gray90"), hover_color=("gray70", "gray30"),
                                         anchor="w", command=self.frame_tools_event)
        self.tools_button.grid(row=3, column=0, sticky="ew")

        self.uninstaller_button = ctk.CTkButton(self.navigation_frame, corner_radius=0, height=40, border_spacing=10, text="🗑️ Uninstaller",
                                               fg_color="transparent", text_color=("gray10", "gray90"), hover_color=("gray70", "gray30"),
                                               anchor="w", command=self.frame_uninstaller_event)
        self.uninstaller_button.grid(row=4, column=0, sticky="ew")

        self.sw_health_button = ctk.CTkButton(self.navigation_frame, corner_radius=0, height=40, border_spacing=10, text="📦 Software Update",
                                              fg_color="transparent", text_color=("gray10", "gray90"), hover_color=("gray70", "gray30"),
                                              anchor="w", command=self.frame_sw_health_event)
        self.sw_health_button.grid(row=5, column=0, sticky="ew")

        self.driver_button = ctk.CTkButton(self.navigation_frame, corner_radius=0, height=40, border_spacing=10, text="🔌 Driver Update",
                                           fg_color="transparent", text_color=("gray10", "gray90"), hover_color=("gray70", "gray30"),
                                           anchor="w", command=self.frame_driver_event)
        self.driver_button.grid(row=6, column=0, sticky="ew")

        self.win_office_button = ctk.CTkButton(self.navigation_frame, corner_radius=0, height=40, border_spacing=10, text="ℹ️ Windows & Office Info",
                                               fg_color="transparent", text_color=("gray10", "gray90"), hover_color=("gray70", "gray30"),
                                               anchor="w", command=self.frame_win_office_event)
        self.win_office_button.grid(row=7, column=0, sticky="ew")

        # Spacer
        self.navigation_frame.grid_rowconfigure(8, weight=1)

        # Exit Button
        self.exit_button = ctk.CTkButton(self.navigation_frame, corner_radius=0, height=40, border_spacing=10, text="🚪 Exit",
                                        fg_color="transparent", text_color=("gray10", "gray90"), hover_color="#880000",
                                        anchor="w", command=self.exit_button_event)
        self.exit_button.grid(row=9, column=0, sticky="ew")
        
        # Admin indicator
        admin_text = "Admin Mode: ACTIVE" if self.is_admin else "Admin Mode: INACTIVE (Restricted)"
        admin_color = "green" if self.is_admin else "red"
        self.admin_label = ctk.CTkLabel(self.navigation_frame, text=admin_text, text_color=admin_color, font=ctk.CTkFont(size=10))
        self.admin_label.grid(row=10, column=0, pady=(20, 10))

        # Create frames
        self.home_frame = ctk.CTkFrame(self, corner_radius=0, fg_color="transparent")
        self.home_frame.grid_columnconfigure(0, weight=1)
        self.setup_home_frame()

        self.cleaner_frame = ctk.CTkFrame(self, corner_radius=0, fg_color="transparent")
        self.setup_cleaner_frame()

        self.tools_frame = ctk.CTkFrame(self, corner_radius=0, fg_color="transparent")
        self.setup_tools_frame()

        self.uninstaller_frame = ctk.CTkFrame(self, corner_radius=0, fg_color="transparent")
        self.setup_uninstaller_frame()

        self.sw_health_frame = ctk.CTkFrame(self, corner_radius=0, fg_color="transparent")
        self.setup_sw_health_frame()

        self.driver_frame = ctk.CTkFrame(self, corner_radius=0, fg_color="transparent")
        self.setup_driver_frame()

        self.win_office_frame = ctk.CTkFrame(self, corner_radius=0, fg_color="transparent")
        self.setup_win_office_frame()

        # Select default frame
        self.select_frame_by_name("home")

    def check_admin(self):
        try:
            return ctypes.windll.shell32.IsUserAnAdmin() # type: ignore
        except:
            return False

    def setup_icon(self):
        """Set up the application icon for window title and taskbar."""
        # This helps Windows identify the app and group its taskbar icon correctly
        myappid = 'tri.pcoptimizer.ultimate.2.0'
        ctypes.windll.shell32.SetCurrentProcessExplicitAppUserModelID(myappid)

        try:
            # Handle path for both script and PyInstaller bundle
            if hasattr(sys, '_MEIPASS'):
                icon_path = os.path.join(sys._MEIPASS, "pc_opt_icon.ico")
            else:
                icon_path = os.path.join(os.path.abspath("."), "pc_opt_icon.ico")

            if os.path.exists(icon_path):
                self.iconbitmap(icon_path)
        except Exception as e:
            print(f"Failed to set icon: {e}")

    def setup_home_frame(self):
        self.home_label = ctk.CTkLabel(self.home_frame, text="System Overview", font=ctk.CTkFont(size=24, weight="bold"))
        self.home_label.grid(row=0, column=0, padx=20, pady=20, sticky="w")
        
        self.specs_textbox = ctk.CTkTextbox(self.home_frame, width=500, height=300, font=ctk.CTkFont(family="Consolas", size=12))
        self.specs_textbox.grid(row=1, column=0, padx=20, pady=10, sticky="nsew")
        self.specs_textbox.insert("0.0", "Fetching system data...")
        self.specs_textbox.configure(state="disabled")
        
        self.refresh_specs_button = ctk.CTkButton(self.home_frame, text="Refresh Stats", command=self.update_specs)
        self.refresh_specs_button.grid(row=2, column=0, padx=20, pady=10, sticky="w")
        
        # Initial stats load
        threading.Thread(target=self.update_specs, daemon=True).start()

    def update_specs(self):
        self.specs_textbox.configure(state="normal")
        self.specs_textbox.delete("0.0", "end")
        self.specs_textbox.insert("end", "Loading...\n")
        
        try:
            specs = sys_info.get_pc_specs()
            text = f"Operating System:  {specs['os']}\n"
            text += f"CPU:               {specs['cpu']}\n"
            text += f"RAM:               {specs['ram']}\n\n"
            text += "Graphics Cards:\n"
            for gpu in specs['gpus']:
                text += f" - {gpu}\n"
            text += "\nStorage Devices:\n"
            for disk in specs['storage']:
                text += f" - {disk}\n"
                
            self.specs_textbox.delete("0.0", "end")
            self.specs_textbox.insert("end", text)
        except Exception as e:
            self.specs_textbox.insert("end", f"Error loading specs: {e}")
            
        self.specs_textbox.configure(state="disabled")

    def setup_cleaner_frame(self):
        self.cleaner_label = ctk.CTkLabel(self.cleaner_frame, text="Deep Junk Cleaner", font=ctk.CTkFont(size=24, weight="bold"))
        self.cleaner_label.grid(row=0, column=0, padx=20, pady=20, sticky="w")
        
        self.check_temp = ctk.CTkCheckBox(self.cleaner_frame, text="Clean Temp Files & Cache")
        self.check_temp.grid(row=1, column=0, padx=20, pady=10, sticky="w")
        self.check_temp.select()
        
        self.check_bin = ctk.CTkCheckBox(self.cleaner_frame, text="Empty Recycle Bin")
        self.check_bin.grid(row=2, column=0, padx=20, pady=10, sticky="w")
        
        self.check_logs = ctk.CTkCheckBox(self.cleaner_frame, text="Clear System Logs")
        self.check_logs.grid(row=3, column=0, padx=20, pady=5, sticky="w")
        
        self.check_empty = ctk.CTkCheckBox(self.cleaner_frame, text="Remove Empty Folders")
        self.check_empty.grid(row=4, column=0, padx=20, pady=5, sticky="w")
        
        self.check_shortcuts = ctk.CTkCheckBox(self.cleaner_frame, text="Remove Broken Shortcuts")
        self.check_shortcuts.grid(row=5, column=0, padx=20, pady=5, sticky="w")
        
        self.check_disk_cleanup = ctk.CTkCheckBox(self.cleaner_frame, text="Run Windows Disk Cleanup")
        self.check_disk_cleanup.grid(row=6, column=0, padx=20, pady=5, sticky="w")
        
        self.run_clean_btn = ctk.CTkButton(self.cleaner_frame, text="Run Selected Cleanup", command=self.run_cleanup_task, fg_color="green", hover_color="darkgreen")
        self.run_clean_btn.grid(row=7, column=0, padx=20, pady=20, sticky="w")
        
        self.refresh_clean_btn = ctk.CTkButton(self.cleaner_frame, text="Refresh (cls)", command=self.refresh_cleaner_frame, fg_color="gray30", hover_color="gray40")
        self.refresh_clean_btn.grid(row=7, column=0, padx=(180, 20), pady=20, sticky="w")
        
        self.select_all_clean_btn = ctk.CTkButton(self.cleaner_frame, text="Select All", command=self.select_all_cleaner, fg_color="gray30", hover_color="gray40")
        self.select_all_clean_btn.grid(row=7, column=0, padx=(340, 20), pady=20, sticky="w")
        
        self.clean_log = ctk.CTkTextbox(self.cleaner_frame, width=600, height=180, font=ctk.CTkFont(family="Consolas", size=11))
        self.clean_log.grid(row=8, column=0, padx=20, pady=10, sticky="nsew")
        self.clean_log.insert("0.0", "Ready.\n")
        self.clean_log.configure(state="disabled")

    def refresh_cleaner_frame(self):
        self.clean_log.configure(state="normal")
        self.clean_log.delete("0.0", "end")
        self.clean_log.insert("end", "Ready.\n")
        self.clean_log.configure(state="disabled")
        
        self.check_temp.select()
        self.check_bin.deselect()
        self.check_logs.deselect()
        self.check_empty.deselect()
        self.check_shortcuts.deselect()
        self.check_disk_cleanup.deselect()

    def select_all_cleaner(self):
        self.check_temp.select()
        self.check_bin.select()
        self.check_logs.select()
        self.check_empty.select()
        self.check_shortcuts.select()
        self.check_disk_cleanup.select()

    def log_clean(self, msg):
        self.clean_log.configure(state="normal")
        self.clean_log.insert("end", msg + "\n")
        self.clean_log.see("end")
        self.clean_log.configure(state="disabled")

    def run_cleanup_task(self):
        self.run_clean_btn.configure(state="disabled")
        self.clean_log.configure(state="normal")
        self.clean_log.delete("0.0", "end")
        self.clean_log.configure(state="disabled")
        
        def task():
            if self.check_temp.get(): cleaner.clean_temp_files(self.log_clean)
            if self.check_bin.get(): cleaner.empty_recycle_bin(self.log_clean)
            if self.check_logs.get(): cleaner.clear_system_logs(self.log_clean)
            if self.check_empty.get(): cleaner.remove_empty_folders(self.log_clean)
            if self.check_shortcuts.get(): cleaner.remove_broken_shortcuts(self.log_clean)
            if self.check_disk_cleanup.get(): cleaner.run_disk_cleanup(self.log_clean)
            self.log_clean("\n--- Cleanup Finished ---")
            self.run_clean_btn.configure(state="normal")
            
        threading.Thread(target=task, daemon=True).start()

    def setup_tools_frame(self):
        self.tools_label = ctk.CTkLabel(self.tools_frame, text="Optimization Tools", font=ctk.CTkFont(size=24, weight="bold"))
        self.tools_label.grid(row=0, column=0, padx=20, pady=20, sticky="w")
        
        self.btn_boost = ctk.CTkButton(self.tools_frame, text="Internet Boost", command=lambda: threading.Thread(target=network_opt.internet_boost, args=(self.log_tool,), daemon=True).start())
        self.btn_boost.grid(row=1, column=0, padx=20, pady=10, sticky="w")
        
        self.btn_reg = ctk.CTkButton(self.tools_frame, text="Optimize Registry", command=lambda: threading.Thread(target=registry_opt.optimize_responsiveness, args=(self.log_tool,), daemon=True).start())
        self.btn_reg.grid(row=2, column=0, padx=20, pady=10, sticky="w")
        
        self.btn_win_upd = ctk.CTkButton(self.tools_frame, text="Disable Win Update", fg_color="red", command=lambda: threading.Thread(target=network_opt.toggle_windows_update, args=(False, self.log_tool), daemon=True).start())
        self.btn_win_upd.grid(row=3, column=0, padx=20, pady=10, sticky="w")
        
        self.btn_disk = ctk.CTkButton(self.tools_frame, text="Run Disk Check (next reboot)", command=lambda: os.system("chkdsk C: /f"))
        self.btn_disk.grid(row=4, column=0, padx=20, pady=10, sticky="w")
        
        self.btn_startup = ctk.CTkButton(self.tools_frame, text="Open Startup Manager", command=lambda: os.system("start taskmgr"))
        self.btn_startup.grid(row=5, column=0, padx=20, pady=10, sticky="w")
        
        self.tool_log = ctk.CTkTextbox(self.tools_frame, width=600, height=200, font=ctk.CTkFont(family="Consolas", size=11))
        self.tool_log.grid(row=6, column=0, padx=20, pady=10, sticky="nsew")
        self.tool_log.configure(state="disabled")

        self.refresh_tool_btn = ctk.CTkButton(self.tools_frame, text="Clear Log (cls)", command=self.refresh_tools_frame, fg_color="gray30", hover_color="gray40")
        self.refresh_tool_btn.grid(row=7, column=0, padx=20, pady=10, sticky="w")

    def refresh_tools_frame(self):
        self.tool_log.configure(state="normal")
        self.tool_log.delete("0.0", "end")
        self.tool_log.configure(state="disabled")

    def log_tool(self, msg):
        self.tool_log.configure(state="normal")
        self.tool_log.insert("end", msg + "\n")
        self.tool_log.see("end")
        self.tool_log.configure(state="disabled")

    def setup_uninstaller_frame(self):
        self.uninstaller_label = ctk.CTkLabel(self.uninstaller_frame, text="Advanced Uninstaller", font=ctk.CTkFont(size=24, weight="bold"))
        self.uninstaller_label.grid(row=0, column=0, padx=20, pady=20, sticky="w")
        
        self.scan_desktop_btn = ctk.CTkButton(self.uninstaller_frame, text="Scan Desktop Apps (.exe/.msi)", command=lambda: self.load_apps("desktop"))
        self.scan_desktop_btn.grid(row=1, column=0, padx=20, pady=10, sticky="w")
        
        self.scan_store_btn = ctk.CTkButton(self.uninstaller_frame, text="Scan Store & System Apps", command=lambda: self.load_apps("store"))
        self.scan_store_btn.grid(row=1, column=0, padx=(230, 20), pady=10, sticky="w")
        
        self.apps_scroll = ctk.CTkScrollableFrame(self.uninstaller_frame, width=650, height=300)
        self.apps_scroll.grid(row=2, column=0, padx=20, pady=10, sticky="nsew")
        
        self.uninst_log = ctk.CTkTextbox(self.uninstaller_frame, width=650, height=100, font=ctk.CTkFont(family="Consolas", size=11))
        self.uninst_log.grid(row=3, column=0, padx=20, pady=10, sticky="nsew")
        self.uninst_log.configure(state="disabled")

        self.refresh_uninst_btn = ctk.CTkButton(self.uninstaller_frame, text="Refresh (cls)", command=self.refresh_uninstaller_frame, fg_color="gray30", hover_color="gray40")
        self.refresh_uninst_btn.grid(row=4, column=0, padx=20, pady=10, sticky="w")

    def refresh_uninstaller_frame(self):
        self.uninst_log.configure(state="normal")
        self.uninst_log.delete("0.0", "end")
        self.uninst_log.configure(state="disabled")
        for widget in self.apps_scroll.winfo_children():
            widget.destroy()

    def load_apps(self, app_type="all"):
        for widget in self.apps_scroll.winfo_children():
            widget.destroy()
            
        def task():
            self.log_uninst(f"[+] Scanning for {app_type} applications...")
            apps = uninstaller.get_installed_apps(app_type)
            
            # Default icon placeholder if needed
            default_icon_path = os.path.join(os.path.dirname(__file__), "pc_opt_icon.ico")
            
            for app in apps:
                frame = ctk.CTkFrame(self.apps_scroll, fg_color="transparent")
                frame.pack(fill="x", padx=5, pady=2)
                
                # Fetch icon
                app_icon = None
                try:
                    pil_img = uninstaller.get_app_icon(app, size=24)
                    if pil_img:
                        app_icon = ctk.CTkImage(light_image=pil_img, dark_image=pil_img, size=(24, 24))
                except:
                    pass
                
                btn = ctk.CTkButton(frame, text=f"  {app['name']}", anchor="w", fg_color="transparent", 
                                   text_color=("gray10", "gray90"), hover_color=("gray70", "gray30"),
                                   image=app_icon,
                                   command=lambda a=app: self.confirm_uninstall(a))
                btn.pack(side="left", fill="x", expand=True)
                
                # Add a cleanup button for each app
                clean_btn = ctk.CTkButton(frame, text="✨ Clean", width=70, height=24, 
                                         fg_color="gray30", hover_color="purple",
                                         command=lambda a=app: threading.Thread(target=uninstaller.remove_leftovers, args=(a['name'], self.log_uninst), daemon=True).start())
                clean_btn.pack(side="right", padx=5)

            self.log_uninst(f"[OK] Found {len(apps)} applications.")
                
        threading.Thread(target=task, daemon=True).start()

    def confirm_uninstall(self, app):
        dialog = ctk.CTkInputDialog(text=f"Type 'YES' to confirm launching uninstaller for {app['name']}:", title="Uninstall Confirm")
        if dialog.get_input() == "YES":
            threading.Thread(target=uninstaller.run_uninstall, args=(app, self.log_uninst), daemon=True).start()

    def log_uninst(self, msg):
        self.uninst_log.configure(state="normal")
        self.uninst_log.insert("end", msg + "\n")
        self.uninst_log.see("end")
        self.uninst_log.configure(state="disabled")

    def setup_sw_health_frame(self):
        self.sw_label = ctk.CTkLabel(self.sw_health_frame, text="Software Update (Winget & Store)", font=ctk.CTkFont(size=24, weight="bold"))
        self.sw_label.grid(row=0, column=0, padx=20, pady=20, sticky="w")
        
        self.sw_scan_btn = ctk.CTkButton(self.sw_health_frame, text="Check for Updates", command=self.scan_sw_updates)
        self.sw_scan_btn.grid(row=1, column=0, padx=20, pady=10, sticky="w")
        
        self.sw_upd_all_btn = ctk.CTkButton(self.sw_health_frame, text="Update All Software", fg_color="green", command=lambda: threading.Thread(target=software_health.upgrade_all, args=(self.log_sw,), daemon=True).start())
        self.sw_upd_all_btn.grid(row=1, column=1, padx=20, pady=10, sticky="w")
        
        self.sw_updates_scroll = ctk.CTkScrollableFrame(self.sw_health_frame, width=650, height=300)
        self.sw_updates_scroll.grid(row=2, column=0, columnspan=2, padx=20, pady=10, sticky="nsew")

        self.sw_log = ctk.CTkTextbox(self.sw_health_frame, width=650, height=80, font=ctk.CTkFont(family="Consolas", size=11))
        self.sw_log.grid(row=3, column=0, columnspan=2, padx=20, pady=10, sticky="nsew")
        self.sw_log.configure(state="disabled")

        self.refresh_sw_btn = ctk.CTkButton(self.sw_health_frame, text="Clear Log (cls)", command=self.refresh_sw_health_frame, fg_color="gray30", hover_color="gray40")
        self.refresh_sw_btn.grid(row=4, column=0, padx=20, pady=10, sticky="w")

    def refresh_sw_health_frame(self):
        self.sw_log.configure(state="normal")
        self.sw_log.delete("0.0", "end")
        self.sw_log.configure(state="disabled")
        for widget in self.sw_updates_scroll.winfo_children():
            widget.destroy()

    def log_sw(self, msg):
        self.sw_log.configure(state="normal")
        self.sw_log.insert("end", msg + "\n")
        self.sw_log.see("end")
        self.sw_log.configure(state="disabled")

    def scan_sw_updates(self):
        self.log_sw("[+] Scanning for updates...")
        for widget in self.sw_updates_scroll.winfo_children():
            widget.destroy()
            
        def task():
            # Get winget list
            winget_apps = software_health.get_upgradable_apps_list(self.log_sw)
            if not winget_apps:
                self.log_sw("[INFO] No updates found.")
                return
            
            # Get installed apps list for enrichment
            self.log_sw("[+] Extracting local app info for icons/publishers...")
            installed_apps = uninstaller.get_installed_apps("all")
            
            # Enrich winget data
            apps = software_health.enrich_app_data(winget_apps, installed_apps)
                
            for app in apps:
                frame = ctk.CTkFrame(self.sw_updates_scroll, corner_radius=10)
                frame.pack(fill="x", padx=10, pady=5)
                
                # Icon part
                icon_label = ctk.CTkLabel(frame, text="", width=40)
                icon_label.pack(side="left", padx=(10, 5))
                
                app_icon = None
                try:
                    # Reuse icon extraction from uninstaller
                    pil_img = uninstaller.get_app_icon(app, size=32)
                    if pil_img:
                        app_icon = ctk.CTkImage(light_image=pil_img, dark_image=pil_img, size=(32, 32))
                        icon_label.configure(image=app_icon)
                except:
                    pass

                # Text Info Part
                info_frame = ctk.CTkFrame(frame, fg_color="transparent")
                info_frame.pack(side="left", padx=5, pady=10, fill="both", expand=True)
                
                name_lbl = ctk.CTkLabel(info_frame, text=app['name'], font=ctk.CTkFont(size=14, weight="bold"), anchor="w")
                name_lbl.pack(fill="x")
                
                publisher_lbl = ctk.CTkLabel(info_frame, text=f"Publisher: {app['publisher']}", font=ctk.CTkFont(size=11), text_color="gray", anchor="w")
                publisher_lbl.pack(fill="x")
                
                # Version Part
                version_frame = ctk.CTkFrame(frame, fg_color="transparent")
                version_frame.pack(side="left", padx=10, pady=10)
                
                ver_text = f"Current: {app['version']}\nNew: {app['available']}"
                ver_lbl = ctk.CTkLabel(version_frame, text=ver_text, font=ctk.CTkFont(size=11), justify="left", anchor="w")
                ver_lbl.pack()
                
                # Update Button
                upd_btn = ctk.CTkButton(frame, text="Update", width=80, height=30, 
                                       fg_color="#1f538d", hover_color="#14375e",
                                       command=lambda a=app: self.run_single_update(a))
                upd_btn.pack(side="right", padx=15)
            
            self.log_sw(f"[OK] Found {len(apps)} updates.")
                
        threading.Thread(target=task, daemon=True).start()

    def run_single_update(self, app):
        def task():
            self.log_sw(f"[+] Updating {app['name']}...")
            success = software_health.upgrade_app(app['id'], self.log_sw)
            if success:
                self.log_sw(f"[OK] Successfully updated {app['name']}")
                # Refresh list after a short delay
                self.after(2000, self.scan_sw_updates)
            else:
                self.log_sw(f"[ERROR] Failed to update {app['name']}")
                
        threading.Thread(target=task, daemon=True).start()

    def setup_driver_frame(self):
        self.dr_label = ctk.CTkLabel(self.driver_frame, text="Driver Update", font=ctk.CTkFont(size=24, weight="bold"))
        self.dr_label.grid(row=0, column=0, padx=20, pady=20, sticky="w")
        
        self.dr_scan_btn = ctk.CTkButton(self.driver_frame, text="Scan for Driver Updates", command=self.scan_drivers)
        self.dr_scan_btn.grid(row=1, column=0, padx=20, pady=10, sticky="w")
        
        self.dr_upd_all_btn = ctk.CTkButton(self.driver_frame, text="Install All Drivers", fg_color="green", command=lambda: threading.Thread(target=driver_update.install_updates, args=(self.log_dr,), daemon=True).start())
        self.dr_upd_all_btn.grid(row=1, column=1, padx=20, pady=10, sticky="w")
        
        self.dr_log = ctk.CTkTextbox(self.driver_frame, width=600, height=400, font=ctk.CTkFont(family="Consolas", size=11))
        self.dr_log.grid(row=2, column=0, columnspan=2, padx=20, pady=10, sticky="nsew")
        self.dr_log.configure(state="disabled")

        self.refresh_dr_btn = ctk.CTkButton(self.driver_frame, text="Clear Log (cls)", command=self.refresh_driver_frame, fg_color="gray30", hover_color="gray40")
        self.refresh_dr_btn.grid(row=3, column=0, padx=20, pady=10, sticky="w")

    def refresh_driver_frame(self):
        self.dr_log.configure(state="normal")
        self.dr_log.delete("0.0", "end")
        self.dr_log.configure(state="disabled")

    def log_dr(self, msg):
        self.dr_log.configure(state="normal")
        self.dr_log.insert("end", msg + "\n")
        self.dr_log.see("end")
        self.dr_log.configure(state="disabled")

    def scan_drivers(self):
        self.dr_log.configure(state="normal")
        self.dr_log.delete("0.0", "end")
        self.dr_log.configure(state="disabled")
        threading.Thread(target=lambda: driver_update.search_updates(self.log_dr), daemon=True).start()

    def setup_win_office_frame(self):
        self.wo_label = ctk.CTkLabel(self.win_office_frame, text="Windows & Office Information", font=ctk.CTkFont(size=24, weight="bold"))
        self.wo_label.grid(row=0, column=0, padx=20, pady=20, sticky="w")
        
        self.wo_scan_btn = ctk.CTkButton(self.win_office_frame, text="Fetch License Info", command=self.update_win_office_info)
        self.wo_scan_btn.grid(row=1, column=0, padx=20, pady=10, sticky="w")
        
        self.wo_textbox = ctk.CTkTextbox(self.win_office_frame, width=650, height=400, font=ctk.CTkFont(family="Consolas", size=12))
        self.wo_textbox.grid(row=2, column=0, padx=20, pady=10, sticky="nsew")
        self.wo_textbox.insert("0.0", "Click 'Fetch License Info' to retrieve details.")
        self.wo_textbox.configure(state="disabled")

        self.refresh_wo_btn = ctk.CTkButton(self.win_office_frame, text="Clear (cls)", command=self.refresh_win_office_frame, fg_color="gray30", hover_color="gray40")
        self.refresh_wo_btn.grid(row=3, column=0, padx=20, pady=10, sticky="w")

    def refresh_win_office_frame(self):
        self.wo_textbox.configure(state="normal")
        self.wo_textbox.delete("0.0", "end")
        self.wo_textbox.insert("0.0", "Click 'Fetch License Info' to retrieve details.")
        self.wo_textbox.configure(state="disabled")

    def update_win_office_info(self):
        self.wo_textbox.configure(state="normal")
        self.wo_textbox.delete("0.0", "end")
        self.wo_textbox.insert("end", "Retrieving information... Please wait.\n")
        self.wo_textbox.configure(state="disabled")
        
        def task():
            try:
                info = sys_info.get_full_license_status()
                text = "WINDOWS LICENSE STATUS:\n"
                text += f"{info['windows']}\n\n"
                text += "OFFICE PRODUCT INFO:\n"
                text += f"Name: {info['office_name']}\n\n"
                text += "OFFICE LICENSE STATUS:\n"
                text += f"{info['office_license']}\n"
                
                self.wo_textbox.configure(state="normal")
                self.wo_textbox.delete("0.0", "end")
                self.wo_textbox.insert("end", text)
                self.wo_textbox.configure(state="disabled")
            except Exception as e:
                self.wo_textbox.configure(state="normal")
                self.wo_textbox.insert("end", f"\nError: {e}")
                self.wo_textbox.configure(state="disabled")

        threading.Thread(target=task, daemon=True).start()

    def select_frame_by_name(self, name):
        # set button color for selected button
        self.home_button.configure(fg_color=("gray75", "gray25") if name == "home" else "transparent")
        self.cleaner_button.configure(fg_color=("gray75", "gray25") if name == "cleaner" else "transparent")
        self.tools_button.configure(fg_color=("gray75", "gray25") if name == "tools" else "transparent")
        self.uninstaller_button.configure(fg_color=("gray75", "gray25") if name == "uninstaller" else "transparent")
        self.sw_health_button.configure(fg_color=("gray75", "gray25") if name == "sw_health" else "transparent")
        self.driver_button.configure(fg_color=("gray75", "gray25") if name == "driver" else "transparent")
        self.win_office_button.configure(fg_color=("gray75", "gray25") if name == "win_office" else "transparent")

        # show selected frame
        if name == "home": self.home_frame.grid(row=0, column=1, sticky="nsew")
        else: self.home_frame.grid_forget()
        if name == "cleaner": self.cleaner_frame.grid(row=0, column=1, sticky="nsew")
        else: self.cleaner_frame.grid_forget()
        if name == "tools": self.tools_frame.grid(row=0, column=1, sticky="nsew")
        else: self.tools_frame.grid_forget()
        if name == "uninstaller": self.uninstaller_frame.grid(row=0, column=1, sticky="nsew")
        else: self.uninstaller_frame.grid_forget()
        if name == "sw_health": self.sw_health_frame.grid(row=0, column=1, sticky="nsew")
        else: self.sw_health_frame.grid_forget()
        if name == "driver": self.driver_frame.grid(row=0, column=1, sticky="nsew")
        else: self.driver_frame.grid_forget()
        if name == "win_office": self.win_office_frame.grid(row=0, column=1, sticky="nsew")
        else: self.win_office_frame.grid_forget()

    def home_button_event(self): self.select_frame_by_name("home")
    def frame_cleaner_event(self): self.select_frame_by_name("cleaner")
    def frame_tools_event(self): self.select_frame_by_name("tools")
    def frame_uninstaller_event(self): self.select_frame_by_name("uninstaller")
    def frame_sw_health_event(self): self.select_frame_by_name("sw_health")
    def frame_driver_event(self): self.select_frame_by_name("driver")
    def frame_win_office_event(self): self.select_frame_by_name("win_office")
    
    def exit_button_event(self):
        self.destroy()
        sys.exit()

if __name__ == "__main__":
    # Self-elevation logic
    if not ctypes.windll.shell32.IsUserAnAdmin(): # type: ignore
        # Re-run as admin
        ctypes.windll.shell32.ShellExecuteW(None, "runas", sys.executable, " ".join(sys.argv), None, 1) # type: ignore
        sys.exit()
        
    app = PCOptimizerApp()
    app.mainloop()
