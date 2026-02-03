<#
.SYNOPSIS
    Driver-Update.ps1 - Windows driver update module
.DESCRIPTION
    Checks and updates device drivers via Windows Update API
.VERSION
    1.0.3 (Fixed)
.AUTHOR
    Brillian Pham (pcoptimizer.seventy907@slmail.me)
#>

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

function Enable-WindowsUpdate {
    Write-Host "`n[+] Initializing Windows Update service..." -ForegroundColor Cyan
    try {
        $service = Get-Service -Name wuauserv -ErrorAction SilentlyContinue
        if ($null -eq $service) {
            Write-Host "[ERROR] Windows Update service (wuauserv) not found!" -ForegroundColor Red
            return $false
        }

        if ($service.StartType -eq 'Disabled') {
            Write-Host "Service is disabled. Enabling..." -ForegroundColor Yellow
            sc.exe config wuauserv start= demand | Out-Null
        }

        if ($service.Status -ne 'Running') {
            Write-Host "Starting service..." -ForegroundColor Yellow
            Start-Service -Name wuauserv -ErrorAction Stop
        }

        Write-Host "[OK] Windows Update service is ready" -ForegroundColor Green
        return $true
    }
    catch {
        Write-Host "[ERROR] Failed to prepare Windows Update service: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

function Get-AvailableDrivers {
    Write-Host "`n[+] Searching for available driver updates..." -ForegroundColor Cyan
    Write-Host "    This process uses official Windows Update servers." -ForegroundColor Gray
    Write-Host "    It may take 1-3 minutes depending on your connection..." -ForegroundColor Gray
    
    try {
        Write-Host "    Initializing update session..." -ForegroundColor Gray
        $updateSession = New-Object -ComObject Microsoft.Update.Session
        if ($null -eq $updateSession) { 
            throw "Could not create Microsoft.Update.Session COM object" 
        }

        $updateSearcher = $updateSession.CreateUpdateSearcher()
        $updateSearcher.Online = $true
        
        Write-Host "    Querying update database..." -ForegroundColor Gray
        $searchResult = $updateSearcher.Search("IsInstalled=0 and Type='Driver'")
        $updates = $searchResult.Updates
        
        Write-Host "    Search completed!" -ForegroundColor Gray
        return $updates
        
    }
    catch {
        Write-Host "`n[ERROR] Driver search failed: $($_.Exception.Message)" -ForegroundColor Red
        if ($_.Exception.Message -match "0x8024402C" -or $_.Exception.Message -match "0x80072EFD") {
            Write-Host "    (Hint: Check your internet connection or firewall settings)" -ForegroundColor Yellow
        }
        return $null
    }
}

function Show-AvailableDrivers {
    Write-Host "`n======================================================" -ForegroundColor Cyan
    Write-Host "         CHECK AVAILABLE DRIVER UPDATES" -ForegroundColor Cyan
    Write-Host "======================================================`n" -ForegroundColor Cyan
    
    if (-not (Enable-WindowsUpdate)) {
        return
    }
    
    $updates = Get-AvailableDrivers
    
    if ($null -eq $updates) {
        Write-Host "[INFO] Driver search could not be completed at this time." -ForegroundColor Yellow
        return
    }
    
    if ($updates.Count -eq 0) {
        Write-Host "`n[SUCCESS] NO DRIVERS NEED UPDATE" -ForegroundColor Green
        Write-Host "All drivers are up to date!`n" -ForegroundColor Green
    }
    else {
        Write-Host "Found $($updates.Count) driver(s) needing update:`n" -ForegroundColor Cyan
        
        $index = 1
        foreach ($update in $updates) {
            Write-Host "[$index] $($update.Title)" -ForegroundColor White
            Write-Host "    - Release Date: $($update.LastDeploymentChangeTime)" -ForegroundColor Gray
            Write-Host "    - Size: $([Math]::Round($update.MaxDownloadSize/1MB, 2)) MB" -ForegroundColor Gray
            Write-Host ""
            $index++
        }
    }
}

function Install-AllDrivers {
    Write-Host "`n======================================================" -ForegroundColor Cyan
    Write-Host "         UPDATE ALL DRIVERS" -ForegroundColor Cyan
    Write-Host "======================================================`n" -ForegroundColor Cyan
    
    Write-Host "This will download and install ALL available drivers." -ForegroundColor Yellow
    Write-Host "Continue? (Y/N): " -ForegroundColor Yellow -NoNewline
    $confirm = Read-Host
    
    if ($confirm -ne 'Y' -and $confirm -ne 'y') {
        Write-Host "`nUpdate cancelled." -ForegroundColor Yellow
        return
    }
    
    if (-not (Enable-WindowsUpdate)) {
        return
    }
    
    Write-Host "`nDownloading and installing drivers..." -ForegroundColor Cyan
    Write-Host "THIS MAY TAKE SEVERAL MINUTES, DO NOT CLOSE THIS WINDOW!" -ForegroundColor Red
    Write-Host ""
    
    try {
        $updates = Get-AvailableDrivers
        if ($null -eq $updates) { return }
        
        $updateSession = New-Object -ComObject Microsoft.Update.Session
        
        if ($updates.Count -eq 0) {
            Write-Host "[INFO] No driver updates available" -ForegroundColor Green
            return
        }
        
        Write-Host "Found $($updates.Count) driver(s). Starting installation...`n" -ForegroundColor Cyan
        
        # Create update collections
        $updatesToDownload = New-Object -ComObject Microsoft.Update.UpdateColl
        $updatesToInstall = New-Object -ComObject Microsoft.Update.UpdateColl
        
        foreach ($update in $updates) {
            $updatesToDownload.Add($update) | Out-Null
        }
        
        # Download
        Write-Host "Downloading drivers..." -ForegroundColor Yellow
        $downloader = $updateSession.CreateUpdateDownloader()
        $downloader.Updates = $updatesToDownload
        $downloadResult = $downloader.Download()
        Write-Host "[OK] Download completed" -ForegroundColor Green
        Write-Host ""
        
        # Prepare install collection
        foreach ($update in $updates) {
            if ($update.IsDownloaded) {
                $updatesToInstall.Add($update) | Out-Null
            }
        }
        
        # Install
        Write-Host "Installing drivers..." -ForegroundColor Yellow
        $installer = $updateSession.CreateUpdateInstaller()
        $installer.Updates = $updatesToInstall
        $installResult = $installer.Install()
        
        Write-Host ""
        Write-Host "======================================================" -ForegroundColor Cyan
        Write-Host "         INSTALLATION RESULTS" -ForegroundColor Cyan
        Write-Host "======================================================`n" -ForegroundColor Cyan
        
        if ($installResult.RebootRequired) {
            Write-Host "[IMPORTANT] RESTART REQUIRED!" -ForegroundColor Red
            Write-Host "Please restart your computer to complete driver installation.`n" -ForegroundColor Yellow
        }
        else {
            Write-Host "[SUCCESS] Installation completed!" -ForegroundColor Green
            Write-Host "No restart required.`n" -ForegroundColor Green
        }
        
        Write-Host "Total installed: $($updatesToInstall.Count) driver(s)" -ForegroundColor Green
        
    }
    catch {
        Write-Host "`n[ERROR] Driver update failed: $($_.Exception.Message)" -ForegroundColor Red
    }
}

function Install-SelectedDrivers {
    Write-Host "`n======================================================" -ForegroundColor Cyan
    Write-Host "         SELECT DRIVERS TO UPDATE" -ForegroundColor Cyan
    Write-Host "======================================================`n" -ForegroundColor Cyan
    
    if (-not (Enable-WindowsUpdate)) {
        return
    }
    
    $updates = Get-AvailableDrivers
    
    if ($null -eq $updates) {
        Write-Host "[INFO] Driver search could not be completed at this time." -ForegroundColor Yellow
        return
    }
    
    if ($updates.Count -eq 0) {
        Write-Host "`n[SUCCESS] No driver updates available!" -ForegroundColor Green
        return
    }
    
    Write-Host "Found $($updates.Count) driver(s):`n" -ForegroundColor Cyan
    
    $index = 1
    foreach ($update in $updates) {
        Write-Host "[$index] $($update.Title)" -ForegroundColor White
        Write-Host "    Size: $([Math]::Round($update.MaxDownloadSize/1MB, 2)) MB" -ForegroundColor Gray
        $index++
    }
    
    Write-Host "`n======================================================" -ForegroundColor Cyan
    Write-Host "Enter driver numbers separated by commas (e.g., 1,3,5)" -ForegroundColor Yellow
    Write-Host "Or enter 'ALL' to update all drivers" -ForegroundColor Yellow
    Write-Host "Or enter '0' to cancel`n" -ForegroundColor Yellow
    
    Write-Host "Your selection: " -ForegroundColor Yellow -NoNewline
    $selection = Read-Host
    
    if ($selection -eq '0') {
        Write-Host "`nCancelled." -ForegroundColor Yellow
        return
    }
    
    if ($selection -eq 'ALL' -or $selection -eq 'all') {
        Install-AllDrivers
        return
    }
    
    # Parse selection
    try {
        $indices = $selection -split ',' | ForEach-Object { [int]$_.Trim() }
        
        Write-Host "`nUpdating selected drivers..." -ForegroundColor Cyan
        
        $updateSession = New-Object -ComObject Microsoft.Update.Session
        $updatesToDownload = New-Object -ComObject Microsoft.Update.UpdateColl
        $updatesToInstall = New-Object -ComObject Microsoft.Update.UpdateColl
        
        foreach ($idx in $indices) {
            if ($idx -le $updates.Count -and $idx -gt 0) {
                $update = $updates.Item($idx - 1)
                Write-Host "Selected: $($update.Title)" -ForegroundColor Cyan
                $updatesToDownload.Add($update) | Out-Null
            }
        }
        
        if ($updatesToDownload.Count -gt 0) {
            Write-Host "`nDownloading drivers..." -ForegroundColor Yellow
            $downloader = $updateSession.CreateUpdateDownloader()
            $downloader.Updates = $updatesToDownload
            $downloadResult = $downloader.Download()
            Write-Host "[OK] Download completed" -ForegroundColor Green
            
            # Prepare install
            foreach ($update in $updatesToDownload) {
                if ($update.IsDownloaded) {
                    $updatesToInstall.Add($update) | Out-Null
                }
            }
            
            Write-Host "`nInstalling drivers..." -ForegroundColor Yellow
            $installer = $updateSession.CreateUpdateInstaller()
            $installer.Updates = $updatesToInstall
            $installResult = $installer.Install()
            
            Write-Host ""
            Write-Host "======================================================" -ForegroundColor Cyan
            Write-Host "         INSTALLATION RESULTS" -ForegroundColor Cyan
            Write-Host "======================================================`n" -ForegroundColor Cyan
            
            if ($installResult.RebootRequired) {
                Write-Host "[IMPORTANT] RESTART REQUIRED!" -ForegroundColor Red
            }
            else {
                Write-Host "[SUCCESS] Installation completed!" -ForegroundColor Green
            }
            
            Write-Host "Installed: $($updatesToInstall.Count) driver(s)" -ForegroundColor Green
        }
        else {
            Write-Host "`nNo drivers selected." -ForegroundColor Yellow
        }
        
    }
    catch {
        Write-Host "`n[ERROR] $($_.Exception.Message)" -ForegroundColor Red
    }
}

# Main execution
Write-Host "======================================================"
Write-Host "         DRIVER UPDATE MODULE"
Write-Host "======================================================"

Write-Host "`n[NOTE] This feature uses Windows Update to find and install drivers." -ForegroundColor Yellow
Write-Host "      Windows Update service will be temporarily enabled.`n" -ForegroundColor Yellow

Write-Host "[1] Check Available Driver Updates"
Write-Host "[2] Update All Drivers"
Write-Host "[3] Update Selected Drivers"
Write-Host "[0] Return to Main Menu"

Write-Host "`nSelect option (0-3): " -ForegroundColor Yellow -NoNewline
$choice = Read-Host

switch ($choice) {
    '1' {
        Show-AvailableDrivers
    }
    '2' {
        Install-AllDrivers
    }
    '3' {
        Install-SelectedDrivers
    }
    '0' {
        Write-Host "`nReturning to main menu..." -ForegroundColor Green
    }
    default {
        Write-Host "`nInvalid selection!" -ForegroundColor Red
    }
}

# FIXED: Replaced problematic ReadKey with standard Read-Host
Write-Host ""
Write-Host "Press ENTER to continue..." -ForegroundColor Gray
Read-Host
