<#
.SYNOPSIS
    Uninstaller.ps1 - Advanced software uninstaller module
.DESCRIPTION
    Lists and uninstalls applications with leftover cleanup
.VERSION
    1.0.3
.AUTHOR
    Brillian Pham (pcoptimizer.seventy907@slmail.me)
#>

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

function Get-InstalledApplications {
    $paths = @(
        'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*',
        'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*',
        'HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*'
    )
    
    $apps = foreach ($path in $paths) {
        Get-ItemProperty $path -ErrorAction SilentlyContinue |
        Where-Object { $_.DisplayName -and ($_.UninstallString -or $_.QuietUninstallString) } |
        ForEach-Object {
            # Infer install location if missing
            $location = if ($_.InstallLocation) { 
                $_.InstallLocation 
            }
            else {
                $uninstStr = $_.UninstallString
                if ($uninstStr -match '"([^"]+)"') {
                    Split-Path $Matches[1] -Parent
                }
                elseif ($uninstStr -match '([^\s]+\.exe)') {
                    Split-Path $Matches[1] -Parent
                }
                else {
                    ''
                }
            }
                
            [PSCustomObject]@{
                Name                 = [string]$_.DisplayName
                UninstallString      = [string]$_.UninstallString
                QuietUninstallString = [string]$_.QuietUninstallString
                InstallLocation      = [string]$location
                Publisher            = if ($_.Publisher) { [string]$_.Publisher } else { 'Unknown' }
            }
        }
    }
    
    return $apps | Sort-Object Name -Unique
}

function Show-ApplicationList {
    param($apps)
    
    Write-Host "`n======================================================" -ForegroundColor Cyan
    Write-Host "              INSTALLED APPLICATIONS" -ForegroundColor Cyan
    Write-Host "======================================================`n" -ForegroundColor Cyan
    
    $index = 1
    foreach ($app in $apps) {
        Write-Host "[$index] $($app.Name)" -ForegroundColor White
        $index++
    }
    
    Write-Host "`n[0] Return to Main Menu" -ForegroundColor Yellow
}

function Invoke-Uninstall {
    param($app)
    
    Write-Host "`n======================================================" -ForegroundColor Cyan
    Write-Host "           UNINSTALL CONFIRMATION" -ForegroundColor Cyan
    Write-Host "======================================================`n" -ForegroundColor Cyan
    
    Write-Host "Application: $($app.Name)" -ForegroundColor White
    Write-Host "Publisher:   $($app.Publisher)" -ForegroundColor White
    Write-Host "Location:    $($app.InstallLocation)" -ForegroundColor White
    
    Write-Host "`nAre you sure you want to uninstall this application? (Y/N): " -ForegroundColor Yellow -NoNewline
    $confirm = Read-Host
    
    if ($confirm -ne 'Y' -and $confirm -ne 'y') {
        Write-Host "`nUninstall cancelled." -ForegroundColor Yellow
        return
    }
    
    Write-Host "`nUninstalling $($app.Name)..." -ForegroundColor Cyan
    
    $uninstallCmd = if ($app.QuietUninstallString) { 
        $app.QuietUninstallString 
    }
    else { 
        $app.UninstallString 
    }
    
    try {
        # Parse command and arguments
        $filePath = ''
        $arguments = ''
        
        if ($uninstallCmd -match '"([^"]+)"(.*)') {
            $filePath = $Matches[1]
            $arguments = $Matches[2].Trim()
        }
        elseif ($uninstallCmd -match '^([^\s]+\.exe|[^\s]+\.msi)\s+(.*)$') {
            $filePath = $Matches[1]
            $arguments = $Matches[2].Trim()
        }
        elseif ($uninstallCmd -match '^msiexec(.*)$') {
            $filePath = 'msiexec.exe'
            $arguments = $Matches[1].Trim()
        }
        else {
            $filePath = $uninstallCmd
        }
        
        Write-Host "Executing: $filePath $arguments" -ForegroundColor Gray
        
        if ($arguments) {
            Start-Process -FilePath $filePath -ArgumentList $arguments -Wait -NoNewWindow -ErrorAction Stop
        }
        else {
            Start-Process -FilePath $filePath -Wait -NoNewWindow -ErrorAction Stop
        }
        
        Write-Host "`n[OK] Uninstall completed successfully!" -ForegroundColor Green
        
    }
    catch {
        Write-Host "`n[ERROR] Uninstall failed: $($_.Exception.Message)" -ForegroundColor Red
        Write-Host "Please try uninstalling manually via Control Panel." -ForegroundColor Yellow
    }
}

function Remove-Leftovers {
    param($app)
    
    Write-Host "`n======================================================" -ForegroundColor Cyan
    Write-Host "           ADVANCED LEFTOVER SCANNING" -ForegroundColor Cyan
    Write-Host "======================================================`n" -ForegroundColor Cyan
    
    Write-Host "Application: $($app.Name)" -ForegroundColor White
    Write-Host "Publisher:   $($app.Publisher)" -ForegroundColor White
    
    # 1. SCAN DIRECTORIES
    Write-Host "`n[+] Searching for leftover folders..." -ForegroundColor Cyan
    
    $searchTerms = @()
    # Add app name and publisher name as search terms
    $searchTerms += ($app.Name -replace '["\^()\[\]{}]', '').Split(' ') | Where-Object { $_.Length -gt 3 }
    if ($app.Publisher -and $app.Publisher -ne 'Unknown') {
        $searchTerms += ($app.Publisher -replace '["\^()\[\]{}]', '').Split(' ') | Where-Object { $_.Length -gt 3 }
    }
    $searchTerms = $searchTerms | Select-Object -Unique
    
    $commonLocations = @(
        $env:APPDATA,
        $env:LOCALAPPDATA,
        'C:\ProgramData',
        'C:\Program Files',
        'C:\Program Files (x86)'
    )
    
    $foundFolders = @()
    
    # Add known install location if it still exists
    if ($app.InstallLocation -and (Test-Path $app.InstallLocation)) {
        $foundFolders += $app.InstallLocation
    }
    
    # Wildcard search in common locations
    foreach ($loc in $commonLocations) {
        if (Test-Path $loc) {
            foreach ($term in $searchTerms) {
                Get-ChildItem -Path "$loc\*$term*" -Directory -ErrorAction SilentlyContinue | ForEach-Object {
                    # Safety check: Avoid adding the root common locations or critical system folders
                    if ($_.FullName -notin $commonLocations -and $_.FullName -notmatch 'Windows|System32|Users$') {
                        $foundFolders += $_.FullName
                    }
                }
            }
        }
    }
    
    $foundFolders = $foundFolders | Select-Object -Unique
    
    if ($foundFolders.Count -gt 0) {
        Write-Host "Found $($foundFolders.Count) possible leftover folder(s):" -ForegroundColor Yellow
        $foundFolders | ForEach-Object { Write-Host "  [DIR] $_" -ForegroundColor Gray }
        
        Write-Host "`nDelete these folders? (Y/N): " -ForegroundColor Yellow -NoNewline
        if ((Read-Host) -match '^[Yy]$') {
            foreach ($folder in $foundFolders) {
                try {
                    if (Test-Path $folder) {
                        Remove-Item $folder -Recurse -Force -ErrorAction Stop
                        Write-Host "[OK] Deleted: $folder" -ForegroundColor Green
                    }
                }
                catch {
                    Write-Host "[!] Access Denied: $folder" -ForegroundColor Red
                }
            }
        }
    }
    else {
        Write-Host "No leftover folders found." -ForegroundColor Gray
    }
    
    # 2. SCAN REGISTRY
    Write-Host "`n[+] Searching for leftover Registry keys..." -ForegroundColor Cyan
    
    $regHives = @('HKLM:\SOFTWARE', 'HKLM:\SOFTWARE\WOW6432Node', 'HKCU:\Software')
    $foundKeys = @()
    
    foreach ($hive in $regHives) {
        if (Test-Path $hive) {
            foreach ($term in $searchTerms) {
                Get-ChildItem -Path $hive -ErrorAction SilentlyContinue | Where-Object { $_.Name -match $term } | ForEach-Object {
                    # Safety check for common high-level keys
                    if ($_.PSChildName -notmatch 'Microsoft|Windows|Classes|Clients') {
                        $foundKeys += $_.PSPath
                    }
                }
            }
        }
    }
    
    $foundKeys = $foundKeys | Select-Object -Unique
    
    if ($foundKeys.Count -gt 0) {
        Write-Host "`nFound $($foundKeys.Count) possible Registry key(s):" -ForegroundColor Yellow
        $foundKeys | ForEach-Object { Write-Host "  [REG] $_" -ForegroundColor Gray }
        
        Write-Host "`nDelete these Registry keys? (Y/N): " -ForegroundColor Yellow -NoNewline
        if ((Read-Host) -match '^[Yy]$') {
            foreach ($key in $foundKeys) {
                try {
                    if (Test-Path $key) {
                        Remove-Item $key -Recurse -Force -ErrorAction Stop
                        Write-Host "[OK] Deleted: $key" -ForegroundColor Green
                    }
                }
                catch {
                    Write-Host "[!] Failed to delete Registry key: $key" -ForegroundColor Red
                }
            }
        }
    }
    else {
        Write-Host "No leftover Registry keys found." -ForegroundColor Gray
    }
}

# Main execution
Write-Host "======================================================"
Write-Host "              SOFTWARE UNINSTALLER"
Write-Host "======================================================"

Write-Host "`nScanning installed applications..." -ForegroundColor Cyan
Write-Host "Please wait...`n" -ForegroundColor Cyan

$apps = Get-InstalledApplications

if (-not $apps -or $apps.Count -eq 0) {
    Write-Host "[ERROR] No applications found!" -ForegroundColor Red
    exit 1
}

do {
    Show-ApplicationList -apps $apps
    
    Write-Host "`nSelect application number to uninstall (0 to exit): " -ForegroundColor Yellow -NoNewline
    $selection = Read-Host
    
    if ($selection -eq '0') {
        break
    }
    
    try {
        $index = [int]$selection - 1
        if ($index -ge 0 -and $index -lt $apps.Count) {
            $selectedApp = $apps[$index]
            Invoke-Uninstall -app $selectedApp
            
            Write-Host "`nScan for leftovers? (Y/N): " -ForegroundColor Yellow -NoNewline
            $scanLeftovers = Read-Host
            
            if ($scanLeftovers -eq 'Y' -or $scanLeftovers -eq 'y') {
                Remove-Leftovers -app $selectedApp
            }
            
            Write-Host "`nPress any key to continue..." -ForegroundColor Gray
            $null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
        }
        else {
            Write-Host "`nInvalid selection!" -ForegroundColor Red
            Start-Sleep -Seconds 2
        }
    }
    catch {
        Write-Host "`nInvalid input!" -ForegroundColor Red
        Start-Sleep -Seconds 2
    }
    
} while ($true)

Write-Host "`nExiting uninstaller..." -ForegroundColor Green
