<#
.SYNOPSIS
    Deep-JunkClean.ps1 - Deep system cleaning module
.DESCRIPTION
    Comprehensive junk file cleanup with multiple cleaning options
.VERSION
    1.0.4
.AUTHOR
    Brillian Pham (pcoptimizer.seventy907@slmail.me)
#>

param(
    [switch]$TempFiles,
    [switch]$RecycleBin,
    [switch]$SystemLogs,
    [switch]$DiskCleanup,
    [switch]$EmptyFolders,
    [switch]$BrokenShortcuts,
    [switch]$All,
    [switch]$ManualSearch
)

# Set console colors
$Host.UI.RawUI.ForegroundColor = "Green"

function Clear-TempFiles {
    Write-Host "`n[+] Cleaning Temp, Prefetch & Cache..." -ForegroundColor Cyan
    
    # Protect current directory if running from Temp
    $origDir = $PSScriptRoot
    
    # Clean user temp
    try {
        Get-ChildItem $env:TEMP -Directory -ErrorAction SilentlyContinue | 
        Where-Object { $_.FullName -ne $origDir } | 
        Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
        
        Get-ChildItem $env:TEMP -File -ErrorAction SilentlyContinue | 
        Remove-Item -Force -ErrorAction SilentlyContinue
        
        Write-Host "[OK] User Temp cleaned!" -ForegroundColor Green
    }
    catch {
        Write-Host "[WARNING] Some temp files could not be deleted (in use)" -ForegroundColor Yellow
    }
    
    # Clean Windows temp
    try {
        Remove-Item "C:\Windows\Temp\*" -Recurse -Force -ErrorAction SilentlyContinue
        Write-Host "[OK] Windows Temp cleaned!" -ForegroundColor Green
    }
    catch {
        Write-Host "[WARNING] Some Windows temp files could not be deleted" -ForegroundColor Yellow
    }
    
    # Clean Prefetch
    try {
        Remove-Item "C:\Windows\Prefetch\*" -Force -ErrorAction SilentlyContinue
        Write-Host "[OK] Prefetch cleaned!" -ForegroundColor Green
    }
    catch {
        Write-Host "[WARNING] Prefetch could not be cleaned" -ForegroundColor Yellow
    }
}

function Invoke-RecycleBinCleanup {
    Write-Host "`n[+] Emptying Recycle Bin..." -ForegroundColor Cyan
    
    try {
        # Try built-in cmdlet with silent error handling (handles "path not found" quirks)
        Clear-RecycleBin -Force -ErrorAction SilentlyContinue
        
        # Manual deep clean for each drive to ensure thoroughness and handle edge cases
        $drives = Get-PSDrive -PSProvider FileSystem | Where-Object { $_.Root -match '^[a-zA-Z]:\\$' }
        foreach ($drive in $drives) {
            $binPath = Join-Path $drive.Root '$Recycle.Bin'
            if (Test-Path $binPath) {
                # Force delete everything inside $Recycle.Bin
                Remove-Item -Path "$binPath\*" -Recurse -Force -ErrorAction SilentlyContinue 2>$null
            }
        }
        
        Write-Host "[OK] Recycle Bin emptied!" -ForegroundColor Green
    }
    catch {
        Write-Host "[WARNING] Could not completely empty Recycle Bin: $_" -ForegroundColor Yellow
    }
}

function Clear-SystemLogs {
    Write-Host "`n[+] Clearing System Event Logs..." -ForegroundColor Cyan
    
    $logs = Get-WinEvent -ListLog * -ErrorAction SilentlyContinue | 
    Where-Object { $_.RecordCount -gt 0 }
    
    $cleared = 0
    foreach ($log in $logs) {
        try {
            wevtutil.exe cl $log.LogName 2>$null
            $cleared++
        }
        catch {
            # Silently continue
        }
    }
    
    Write-Host "[OK] Cleared $cleared event logs!" -ForegroundColor Green
}

function Start-DiskCleanup {
    Write-Host "`n[+] Running Windows Disk Cleanup..." -ForegroundColor Cyan
    
    try {
        Start-Process cleanmgr -ArgumentList "/sagerun:1" -Wait -NoNewWindow
        Write-Host "[OK] Disk Cleanup completed!" -ForegroundColor Green
    }
    catch {
        Write-Host "[ERROR] Could not run Disk Cleanup: $_" -ForegroundColor Red
    }
}

function Remove-EmptyFolders {
    Write-Host "`n[+] Scanning for empty folders..." -ForegroundColor Cyan
    
    $roots = @(
        'C:\ProgramData',
        $env:APPDATA,
        $env:LOCALAPPDATA,
        'C:\Program Files',
        'C:\Program Files (x86)'
    )
    
    $emptyFolders = @()
    
    foreach ($root in $roots) {
        if (Test-Path $root) {
            Write-Host "  Scanning: $root" -ForegroundColor Gray
            
            Get-ChildItem -Path $root -Directory -Recurse -Force -ErrorAction SilentlyContinue |
            Where-Object { (Get-ChildItem $_.FullName -Force -ErrorAction SilentlyContinue).Count -eq 0 } |
            ForEach-Object { $emptyFolders += $_.FullName }
        }
    }
    
    # Sort by depth (deepest first)
    $emptyFolders = $emptyFolders | Sort-Object { $_.Length } -Descending
    
    Write-Host "`nFound $($emptyFolders.Count) empty folders" -ForegroundColor Cyan
    
    if ($emptyFolders.Count -gt 0) {
        Write-Host "`nSample folders (first 10):" -ForegroundColor Yellow
        $emptyFolders | Select-Object -First 10 | ForEach-Object { Write-Host "  $_" -ForegroundColor Gray }
        
        Write-Host "`nPress Y to delete all empty folders, or any other key to skip..." -ForegroundColor Yellow
        $confirm = Read-Host
        
        if ($confirm -eq 'Y' -or $confirm -eq 'y') {
            $removed = 0
            foreach ($folder in $emptyFolders) {
                try {
                    if (Test-Path $folder -PathType Container) {
                        Remove-Item $folder -Force -Recurse -ErrorAction Stop
                        $removed++
                    }
                }
                catch {
                    # Silently continue
                }
            }
            Write-Host "[OK] Removed $removed empty folders!" -ForegroundColor Green
        }
        else {
            Write-Host "[SKIP] Skipped empty folder removal" -ForegroundColor Yellow
        }
    }
    else {
        Write-Host "[OK] No empty folders found!" -ForegroundColor Green
    }
}

function Remove-BrokenShortcuts {
    Write-Host "`n[+] Removing broken shortcuts..." -ForegroundColor Cyan
    
    $scriptPath = Join-Path $PSScriptRoot "Remove-BrokenShortcuts.ps1"
    
    if (Test-Path $scriptPath) {
        try {
            & $scriptPath
        }
        catch {
            Write-Host "[ERROR] Could not run Remove-BrokenShortcuts.ps1: $_" -ForegroundColor Red
        }
    }
    else {
        Write-Host "[WARNING] Remove-BrokenShortcuts.ps1 not found in script directory" -ForegroundColor Yellow
    }
}

function Invoke-ManualSearch {
    Write-Host "`n======================================================" -ForegroundColor Cyan
    Write-Host "         MANUAL SEARCH & DELETE" -ForegroundColor Cyan
    Write-Host "======================================================" -ForegroundColor Cyan
    Write-Host "`nType '0' to return to menu" -ForegroundColor Gray
    
    $appName = Read-Host "`nEnter application name to search"
    
    # Check if user wants to exit or input is empty
    if ($appName -eq '0') {
        Write-Host "`n[RETURNING] Going back to main menu..." -ForegroundColor Green
        return
    }
    
    if ([string]::IsNullOrWhiteSpace($appName)) {
        Write-Host "`n[ERROR] Please enter a valid application name!" -ForegroundColor Red
        Write-Host "[RETURNING] Going back to main menu..." -ForegroundColor Green
        return
    }
    
    Write-Host "`n=== Searching for: $appName ===" -ForegroundColor Yellow
    
    $searchLocations = @{
        "Program Files"       = "C:\Program Files"
        "Program Files (x86)" = "C:\Program Files (x86)"
        "AppData Roaming"     = "$env:APPDATA"
        "AppData Local"       = "$env:LOCALAPPDATA"
        "AppData LocalLow"    = "$env:USERPROFILE\AppData\LocalLow"
        "ProgramData"         = "C:\ProgramData"
        "User Documents"      = "$env:USERPROFILE\Documents"
        "Desktop"             = "$env:USERPROFILE\Desktop"
        "Start Menu"          = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs"
        "Common Start Menu"   = "C:\ProgramData\Microsoft\Windows\Start Menu\Programs"
        "Temp"                = "$env:TEMP"
    }
    
    $foundItems = @()
    
    foreach ($location in $searchLocations.GetEnumerator()) {
        Write-Host "`nSearching in $($location.Key)..." -ForegroundColor Cyan
        
        if (Test-Path $location.Value) {
            $items = Get-ChildItem -Path $location.Value -Recurse -ErrorAction SilentlyContinue | 
            Where-Object { $_.Name -like "*$appName*" }
            
            if ($items) {
                foreach ($item in $items) {
                    Write-Host "  Found: $($item.FullName)" -ForegroundColor Green
                    $foundItems += $item.FullName
                }
            }
        }
    }
    
    # Search in Registry
    Write-Host "`nSearching in Registry..." -ForegroundColor Cyan
    $regLocations = @(
        "HKLM\SOFTWARE",
        "HKLM\SOFTWARE\WOW6432Node",
        "HKCU\SOFTWARE"
    )
    
    foreach ($regPath in $regLocations) {
        $regResults = reg query $regPath /f $appName /s /k 2>$null
        if ($regResults) {
            $regResults | Where-Object { $_ -match "^HK" } | ForEach-Object {
                Write-Host "  Registry: $_" -ForegroundColor Yellow
                $foundItems += "Registry: $_"
            }
        }
    }
    
    Write-Host "`n=== Summary ===" -ForegroundColor Yellow
    Write-Host "Total items found: $($foundItems.Count)" -ForegroundColor Green
    
    # Delete option
    if ($foundItems.Count -gt 0) {
        $delete = Read-Host "`nDo you want to delete all found items? (Type YES to confirm)"
        
        if ($delete -eq "YES") {
            foreach ($item in $foundItems) {
                if ($item -like "Registry:*") {
                    $regKey = $item -replace "Registry: ", ""
                    Write-Host "Deleting registry: $regKey" -ForegroundColor Red
                    reg delete $regKey /f 2>$null
                }
                else {
                    Write-Host "Deleting: $item" -ForegroundColor Red
                    Remove-Item -Path $item -Recurse -Force -ErrorAction SilentlyContinue
                }
            }
            Write-Host "`nCleanup completed!" -ForegroundColor Green
        }
    }
    
    Write-Host "`n[RETURNING] Going back to main menu..." -ForegroundColor Green
}

# Main execution
Write-Host "======================================================"
Write-Host "             DEEP JUNK CLEAN MODULE"
Write-Host "======================================================"

if ($All) {
    Clear-TempFiles
    Invoke-RecycleBinCleanup
    Clear-SystemLogs
    Start-DiskCleanup
    Remove-EmptyFolders
    Remove-BrokenShortcuts
}
else {
    if ($TempFiles) { Clear-TempFiles }
    if ($RecycleBin) { Invoke-RecycleBinCleanup }
    if ($SystemLogs) { Clear-SystemLogs }
    if ($DiskCleanup) { Start-DiskCleanup }
    if ($EmptyFolders) { Remove-EmptyFolders }
    if ($BrokenShortcuts) { Remove-BrokenShortcuts }
    if ($ManualSearch) { Invoke-ManualSearch }
}

Write-Host "`n======================================================"
Write-Host "         CLEANUP COMPLETED SUCCESSFULLY!"
Write-Host "======================================================`n"
