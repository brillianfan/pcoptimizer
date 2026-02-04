<#
.SYNOPSIS
    Deep-JunkClean.ps1 - Deep system cleaning module
.DESCRIPTION
    Comprehensive junk file cleanup with multiple cleaning options
.VERSION
    1.0.3
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
    
    do {
        Write-Host "`n[SEARCH OPTIONS]" -ForegroundColor Yellow
        Write-Host "Enter keyword to search for in files, folders, and registry:" -ForegroundColor Gray
        Write-Host "Type 'exit' to return to main menu" -ForegroundColor Gray
        Write-Host "Keyword: " -ForegroundColor Yellow -NoNewline
        $keyword = Read-Host
        
        if ($keyword -eq 'exit') { break }
        if ([string]::IsNullOrWhiteSpace($keyword)) {
            Write-Host "[ERROR] Please enter a valid keyword!" -ForegroundColor Red
            continue
        }
        
        Write-Host "`n[SEARCHING] Please wait, this may take a while..." -ForegroundColor Yellow
        
        # Search in C: drive
        Write-Host "`n[1] Searching in C: drive..." -ForegroundColor Cyan
        $filesFound = @()
        $foldersFound = @()
        
        try {
            # Search for files and folders
            $filesFound = Get-ChildItem -Path "C:\" -Recurse -File -ErrorAction SilentlyContinue | 
                Where-Object { $_.Name -like "*$keyword*" -or $_.DirectoryName -like "*$keyword*" } |
                Select-Object -First 50 # Limit to 50 results for performance
                
            $foldersFound = Get-ChildItem -Path "C:\" -Recurse -Directory -ErrorAction SilentlyContinue | 
                Where-Object { $_.Name -like "*$keyword*" } |
                Select-Object -First 30 # Limit to 30 results for performance
        }
        catch {
            Write-Host "[WARNING] Some directories could not be accessed (permission denied)" -ForegroundColor Yellow
        }
        
        # Search in Registry
        Write-Host "[2] Searching in Registry..." -ForegroundColor Cyan
        $registryKeys = @()
        
        try {
            # Search in HKLM
            $registryKeys += Get-ChildItem -Path "HKLM:\SOFTWARE" -Recurse -ErrorAction SilentlyContinue | 
                Where-Object { $_.Name -like "*$keyword*" } |
                Select-Object -First 20
                
            $registryKeys += Get-ChildItem -Path "HKLM:\SYSTEM" -Recurse -ErrorAction SilentlyContinue | 
                Where-Object { $_.Name -like "*$keyword*" } |
                Select-Object -First 20
                
            # Search in HKCU
            $registryKeys += Get-ChildItem -Path "HKCU:\SOFTWARE" -Recurse -ErrorAction SilentlyContinue | 
                Where-Object { $_.Name -like "*$keyword*" } |
                Select-Object -First 20
        }
        catch {
            Write-Host "[WARNING] Some registry keys could not be accessed" -ForegroundColor Yellow
        }
        
        # Display results
        Write-Host "`n======================================================" -ForegroundColor Green
        Write-Host "              SEARCH RESULTS" -ForegroundColor Green
        Write-Host "======================================================" -ForegroundColor Green
        
        $totalFound = $filesFound.Count + $foldersFound.Count + $registryKeys.Count
        
        if ($totalFound -eq 0) {
            Write-Host "`n[RESULT] No items found containing keyword: '$keyword'" -ForegroundColor Yellow
            Write-Host "Try searching with a different keyword." -ForegroundColor Gray
        }
        else {
            Write-Host "`n[RESULT] Found $totalFound item(s) containing keyword: '$keyword'" -ForegroundColor Green
            
            # Display files
            if ($filesFound.Count -gt 0) {
                Write-Host "`n--- FILES ($($filesFound.Count) found) ---" -ForegroundColor White
                for ($i = 0; $i -lt $filesFound.Count; $i++) {
                    $size = [math]::Round($filesFound[$i].Length / 1MB, 2)
                    Write-Host "[$($i+1)] $($filesFound[$i].FullName) ($size MB)" -ForegroundColor Gray
                }
            }
            
            # Display folders
            if ($foldersFound.Count -gt 0) {
                Write-Host "`n--- FOLDERS ($($foldersFound.Count) found) ---" -ForegroundColor White
                for ($i = 0; $i -lt $foldersFound.Count; $i++) {
                    Write-Host "[$($filesFound.Count + $i + 1)] $($foldersFound[$i].FullName)" -ForegroundColor Gray
                }
            }
            
            # Display registry keys
            if ($registryKeys.Count -gt 0) {
                Write-Host "`n--- REGISTRY KEYS ($($registryKeys.Count) found) ---" -ForegroundColor White
                for ($i = 0; $i -lt $registryKeys.Count; $i++) {
                    Write-Host "[$($filesFound.Count + $foldersFound.Count + $i + 1)] $($registryKeys[$i].Name)" -ForegroundColor Magenta
                }
            }
            
            # Ask for deletion
            Write-Host "`n======================================================" -ForegroundColor Yellow
            Write-Host "Do you want to DELETE all found items?" -ForegroundColor Yellow
            Write-Host "WARNING: This action cannot be undone!" -ForegroundColor Red
            Write-Host "Type 'YES' to confirm, anything else to cancel: " -ForegroundColor Yellow -NoNewline
            $confirm = Read-Host
            
            if ($confirm -eq 'YES') {
                Write-Host "`n[DELETING] Please wait..." -ForegroundColor Red
                
                $deletedFiles = 0
                $deletedFolders = 0
                $deletedRegistry = 0
                
                # Delete files
                foreach ($file in $filesFound) {
                    try {
                        Remove-Item -Path $file.FullName -Force -Recurse -ErrorAction SilentlyContinue
                        $deletedFiles++
                        Write-Host "[DELETED] File: $($file.Name)" -ForegroundColor Green
                    }
                    catch {
                        Write-Host "[FAILED] File: $($file.Name) - $($_.Exception.Message)" -ForegroundColor Red
                    }
                }
                
                # Delete folders
                foreach ($folder in $foldersFound) {
                    try {
                        Remove-Item -Path $folder.FullName -Force -Recurse -ErrorAction SilentlyContinue
                        $deletedFolders++
                        Write-Host "[DELETED] Folder: $($folder.Name)" -ForegroundColor Green
                    }
                    catch {
                        Write-Host "[FAILED] Folder: $($folder.Name) - $($_.Exception.Message)" -ForegroundColor Red
                    }
                }
                
                # Delete registry keys
                foreach ($key in $registryKeys) {
                    try {
                        Remove-Item -Path $key.Name -Force -Recurse -ErrorAction SilentlyContinue
                        $deletedRegistry++
                        Write-Host "[DELETED] Registry: $($key.Name)" -ForegroundColor Green
                    }
                    catch {
                        Write-Host "[FAILED] Registry: $($key.Name) - $($_.Exception.Message)" -ForegroundColor Red
                    }
                }
                
                Write-Host "`n[SUMMARY] Deletion completed!" -ForegroundColor Green
                Write-Host "Files deleted: $deletedFiles" -ForegroundColor Cyan
                Write-Host "Folders deleted: $deletedFolders" -ForegroundColor Cyan
                Write-Host "Registry keys deleted: $deletedRegistry" -ForegroundColor Cyan
            }
            else {
                Write-Host "`n[CANCELLED] No items were deleted." -ForegroundColor Yellow
            }
        }
        
        Write-Host "`n======================================================" -ForegroundColor Cyan
        Write-Host "Search again? (Y/N): " -ForegroundColor Yellow -NoNewline
        $searchAgain = Read-Host
        
    } while ($searchAgain -eq 'Y' -or $searchAgain -eq 'y')
    
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
