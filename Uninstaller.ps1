<#
.SYNOPSIS
    Uninstaller.ps1 - Advanced software uninstaller module
.DESCRIPTION
    Lists and uninstalls applications with leftover cleanup
.VERSION
    1.0.2
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
                } else {
                    $uninstStr = $_.UninstallString
                    if ($uninstStr -match '"([^"]+)"') {
                        Split-Path $Matches[1] -Parent
                    } elseif ($uninstStr -match '([^\s]+\.exe)') {
                        Split-Path $Matches[1] -Parent
                    } else {
                        ''
                    }
                }
                
                [PSCustomObject]@{
                    Name = [string]$_.DisplayName
                    UninstallString = [string]$_.UninstallString
                    QuietUninstallString = [string]$_.QuietUninstallString
                    InstallLocation = [string]$location
                    Publisher = if ($_.Publisher) { [string]$_.Publisher } else { 'Unknown' }
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
    } else { 
        $app.UninstallString 
    }
    
    try {
        # Parse command and arguments
        $filePath = ''
        $arguments = ''
        
        if ($uninstallCmd -match '"([^"]+)"(.*)') {
            $filePath = $Matches[1]
            $arguments = $Matches[2].Trim()
        } elseif ($uninstallCmd -match '^([^\s]+\.exe|[^\s]+\.msi)\s+(.*)$') {
            $filePath = $Matches[1]
            $arguments = $Matches[2].Trim()
        } elseif ($uninstallCmd -match '^msiexec(.*)$') {
            $filePath = 'msiexec.exe'
            $arguments = $Matches[1].Trim()
        } else {
            $filePath = $uninstallCmd
        }
        
        Write-Host "Executing: $filePath $arguments" -ForegroundColor Gray
        
        if ($arguments) {
            Start-Process -FilePath $filePath -ArgumentList $arguments -Wait -NoNewWindow -ErrorAction Stop
        } else {
            Start-Process -FilePath $filePath -Wait -NoNewWindow -ErrorAction Stop
        }
        
        Write-Host "`n[OK] Uninstall completed successfully!" -ForegroundColor Green
        
    } catch {
        Write-Host "`n[ERROR] Uninstall failed: $($_.Exception.Message)" -ForegroundColor Red
        Write-Host "Please try uninstalling manually via Control Panel." -ForegroundColor Yellow
    }
}

function Remove-Leftovers {
    param($app)
    
    Write-Host "`n======================================================" -ForegroundColor Cyan
    Write-Host "           SCANNING FOR LEFTOVERS" -ForegroundColor Cyan
    Write-Host "======================================================`n" -ForegroundColor Cyan
    
    Write-Host "Application: $($app.Name)" -ForegroundColor White
    Write-Host "Publisher:   $($app.Publisher)" -ForegroundColor White
    Write-Host "`nScanning for leftover files..." -ForegroundColor Cyan
    
    $leftovers = @()
    
    # Check install location
    if ($app.InstallLocation -and (Test-Path $app.InstallLocation)) {
        $leftovers += $app.InstallLocation
        Write-Host "[FOUND] $($app.InstallLocation)" -ForegroundColor Yellow
    }
    
    # Sanitize search names
    $searchName = $app.Name -replace '["\^()]', ''
    $searchPublisher = $app.Publisher -replace '["\^()]', ''
    
    # Check common locations
    $locations = @(
        $env:APPDATA,
        $env:LOCALAPPDATA,
        'C:\ProgramData',
        'C:\Program Files',
        'C:\Program Files (x86)'
    )
    
    foreach ($location in $locations) {
        if (Test-Path $location) {
            # Search by app name
            if ($searchName) {
                $path = Join-Path $location $searchName
                if (Test-Path $path) {
                    $leftovers += $path
                    Write-Host "[FOUND] $path" -ForegroundColor Yellow
                }
            }
            
            # Search by publisher
            if ($searchPublisher -and $searchPublisher -ne 'Unknown') {
                $path = Join-Path $location $searchPublisher
                if (Test-Path $path) {
                    $leftovers += $path
                    Write-Host "[FOUND] $path" -ForegroundColor Yellow
                }
            }
        }
    }
    
    # Remove duplicates
    $leftovers = $leftovers | Select-Object -Unique
    
    Write-Host "`n======================================================" -ForegroundColor Cyan
    Write-Host "           LEFTOVER SCAN RESULTS" -ForegroundColor Cyan
    Write-Host "======================================================`n" -ForegroundColor Cyan
    
    if ($leftovers.Count -eq 0) {
        Write-Host "No leftovers found!" -ForegroundColor Green
        return
    }
    
    Write-Host "Found $($leftovers.Count) leftover folder(s):`n" -ForegroundColor Yellow
    $leftovers | ForEach-Object { Write-Host "  $_" -ForegroundColor Gray }
    
    Write-Host "`nDelete ALL these folders? (Y/N): " -ForegroundColor Yellow -NoNewline
    $confirm = Read-Host
    
    if ($confirm -eq 'Y' -or $confirm -eq 'y') {
        Write-Host ""
        foreach ($folder in $leftovers) {
            if (Test-Path $folder) {
                Write-Host "Deleting: $folder" -ForegroundColor Cyan
                try {
                    Remove-Item $folder -Recurse -Force -ErrorAction Stop
                    Write-Host "[OK] Deleted successfully" -ForegroundColor Green
                } catch {
                    Write-Host "[!] Could not delete: $folder" -ForegroundColor Red
                }
            }
        }
    } else {
        Write-Host "`nLeftover cleanup cancelled." -ForegroundColor Yellow
    }
    
    # Scan Registry
    Write-Host "`n======================================================" -ForegroundColor Cyan
    Write-Host "           SCANNING REGISTRY" -ForegroundColor Cyan
    Write-Host "======================================================`n" -ForegroundColor Cyan
    
    $regKeys = @()
    $regPaths = @(
        'HKLM:\SOFTWARE',
        'HKLM:\SOFTWARE\WOW6432Node',
        'HKCU:\Software'
    )
    
    foreach ($regPath in $regPaths) {
        try {
            Get-ChildItem $regPath -ErrorAction SilentlyContinue |
                Where-Object { 
                    $_.PSChildName -eq $searchName -or 
                    ($searchPublisher -and $_.PSChildName -eq $searchPublisher) 
                } |
                ForEach-Object {
                    $regKeys += $_.PSPath
                    Write-Host "[FOUND REG] $($_.PSPath)" -ForegroundColor Yellow
                }
        } catch {
            # Silently continue
        }
    }
    
    if ($regKeys.Count -gt 0) {
        Write-Host "`nDelete these registry keys? (Y/N): " -ForegroundColor Yellow -NoNewline
        $confirmReg = Read-Host
        
        if ($confirmReg -eq 'Y' -or $confirmReg -eq 'y') {
            Write-Host ""
            foreach ($key in $regKeys) {
                if (Test-Path $key) {
                    try {
                        Remove-Item $key -Recurse -Force -ErrorAction Stop
                        Write-Host "[OK] Deleted registry: $key" -ForegroundColor Green
                    } catch {
                        Write-Host "[ERROR] Could not delete: $key" -ForegroundColor Red
                    }
                }
            }
        }
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
        } else {
            Write-Host "`nInvalid selection!" -ForegroundColor Red
            Start-Sleep -Seconds 2
        }
    } catch {
        Write-Host "`nInvalid input!" -ForegroundColor Red
        Start-Sleep -Seconds 2
    }
    
} while ($true)

Write-Host "`nExiting uninstaller..." -ForegroundColor Green
