<#
.SYNOPSIS
    Software-Health.ps1 - Software update management module
.DESCRIPTION
    Manages software updates via Windows Package Manager (Winget)
.VERSION
    1.0.4
.AUTHOR
    Brillian Pham (pcoptimizer.seventy907@slmail.me)
#>

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

function Test-WingetInstalled {
    try {
        Get-Command winget -ErrorAction Stop | Out-Null
        return $true
    }
    catch {
        return $false
    }
}

function Enable-WindowsUpdate {
    Write-Host "`nEnabling Windows Update service..." -ForegroundColor Cyan
    try {
        sc.exe config wuauserv start= demand | Out-Null
        net start wuauserv 2>&1 | Out-Null
        Write-Host "[OK] Windows Update service enabled" -ForegroundColor Green
    }
    catch {
        Write-Host "[WARNING] Could not enable Windows Update" -ForegroundColor Yellow
    }
}

function Update-AllSoftware {
    Write-Host "`n======================================================" -ForegroundColor Cyan
    Write-Host "         UPDATE ALL SOFTWARE" -ForegroundColor Cyan
    Write-Host "======================================================`n" -ForegroundColor Cyan
    
    Write-Host "Checking for available updates..." -ForegroundColor Yellow
    Write-Host "This may take a few moments...`n" -ForegroundColor Gray
    
    try {
        winget upgrade --all --accept-package-agreements --accept-source-agreements
        
        Write-Host "`n======================================================" -ForegroundColor Cyan
        Write-Host "         UPDATE COMPLETED!" -ForegroundColor Cyan
        Write-Host "======================================================`n" -ForegroundColor Cyan
        
    }
    catch {
        Write-Host "`n[ERROR] Update failed: $($_.Exception.Message)" -ForegroundColor Red
    }
}

function Update-SelectedSoftware {
    Write-Host "`n======================================================" -ForegroundColor Cyan
    Write-Host "         SELECT SOFTWARE TO UPDATE" -ForegroundColor Cyan
    Write-Host "======================================================`n" -ForegroundColor Cyan
    
    Write-Host "Fetching available updates..." -ForegroundColor Yellow
    Write-Host "Please wait...`n" -ForegroundColor Gray
    
    try {
        winget list --upgrade-available
        
        if ($LASTEXITCODE -ne 0) {
            Write-Host "`n[ERROR] Could not fetch update list" -ForegroundColor Red
            Write-Host "Possible reasons:" -ForegroundColor Yellow
            Write-Host "  - No updates available" -ForegroundColor Gray
            Write-Host "  - Network connection issue" -ForegroundColor Gray
            Write-Host "  - Winget service unavailable" -ForegroundColor Gray
            return
        }
        
        Write-Host "`n======================================================" -ForegroundColor Cyan
        Write-Host "         UPDATE SPECIFIC SOFTWARE" -ForegroundColor Cyan
        Write-Host "======================================================`n" -ForegroundColor Cyan
        
        Write-Host "Instructions: Copy the 'ID' from column 2 and paste below" -ForegroundColor Yellow
        Write-Host "Example: Google.Chrome`n" -ForegroundColor Gray
        Write-Host "[0] Return to menu" -ForegroundColor Yellow
        Write-Host "[1] Cancel`n" -ForegroundColor Yellow
        
        do {
            Write-Host "Enter software ID: " -ForegroundColor Yellow -NoNewline
            $softwareId = Read-Host
            
            if ([string]::IsNullOrWhiteSpace($softwareId)) {
                Write-Host "Please enter a valid ID!" -ForegroundColor Red
                Start-Sleep -Seconds 1
                continue
            }
            
            if ($softwareId -eq '0') {
                return
            }
            
            if ($softwareId -eq '1') {
                Write-Host "`nCancelled." -ForegroundColor Yellow
                return
            }
            
            Write-Host "`nUpdating: $softwareId..." -ForegroundColor Cyan
            
            try {
                winget upgrade --id $softwareId --accept-package-agreements --accept-source-agreements
                
                if ($LASTEXITCODE -eq 0) {
                    Write-Host "`n[SUCCESS] $softwareId updated successfully!" -ForegroundColor Green
                }
                else {
                    Write-Host "`n[ERROR] Could not update $softwareId" -ForegroundColor Red
                    Write-Host "`nWould you like to:" -ForegroundColor Yellow
                    Write-Host "[1] Retry" -ForegroundColor White
                    Write-Host "[2] Force update (bypass hash check)" -ForegroundColor White
                    Write-Host "[3] Skip" -ForegroundColor White
                    
                    Write-Host "`nChoice: " -ForegroundColor Yellow -NoNewline
                    $retryChoice = Read-Host
                    
                    switch ($retryChoice) {
                        '1' {
                            Write-Host "`nRetrying..." -ForegroundColor Cyan
                            winget upgrade --id $softwareId --accept-package-agreements --accept-source-agreements
                        }
                        '2' {
                            Write-Host "`nForcing update..." -ForegroundColor Cyan
                            winget upgrade --id $softwareId --force --accept-package-agreements --accept-source-agreements
                        }
                        '3' {
                            Write-Host "`nSkipped." -ForegroundColor Yellow
                        }
                    }
                }
            }
            catch {
                Write-Host "`n[ERROR] Update failed: $($_.Exception.Message)" -ForegroundColor Red
            }
            
            Write-Host "`nUpdate another software? (Y/N): " -ForegroundColor Yellow -NoNewline
            $continue = Read-Host
            
            if ($continue -ne 'Y' -and $continue -ne 'y') {
                break
            }
            
        } while ($true)
        
    }
    catch {
        Write-Host "`n[ERROR] Could not fetch update list: $($_.Exception.Message)" -ForegroundColor Red
    }
}

function Show-InstalledSoftware {
    Write-Host "`n======================================================" -ForegroundColor Cyan
    Write-Host "         INSTALLED SOFTWARE LIST" -ForegroundColor Cyan
    Write-Host "======================================================`n" -ForegroundColor Cyan
    
    Write-Host "Fetching installed software..." -ForegroundColor Yellow
    Write-Host "Please wait...`n" -ForegroundColor Gray
    
    try {
        winget list
    }
    catch {
        Write-Host "`n[ERROR] Could not fetch installed software: $($_.Exception.Message)" -ForegroundColor Red
    }
}

function Search-Software {
    Write-Host "`n======================================================" -ForegroundColor Cyan
    Write-Host "         SEARCH SOFTWARE" -ForegroundColor Cyan
    Write-Host "======================================================`n" -ForegroundColor Cyan
    
    Write-Host "Enter software name to search: " -ForegroundColor Yellow -NoNewline
    $searchQuery = Read-Host
    
    if ([string]::IsNullOrWhiteSpace($searchQuery)) {
        Write-Host "`nSearch cancelled." -ForegroundColor Yellow
        return
    }
    
    Write-Host "`nSearching for: $searchQuery..." -ForegroundColor Cyan
    
    try {
        winget search $searchQuery
    }
    catch {
        Write-Host "`n[ERROR] Search failed: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# Main execution
Write-Host "======================================================"
Write-Host "         SOFTWARE HEALTH MODULE"
Write-Host "======================================================"

# Check Winget installation
if (-not (Test-WingetInstalled)) {
    Write-Host "`n[ERROR] Windows Package Manager (Winget) is not installed!" -ForegroundColor Red
    Write-Host "`nWinget is required for this feature." -ForegroundColor Yellow
    Write-Host "Please install Winget from Microsoft Store (App Installer)." -ForegroundColor Yellow
    Write-Host "`nPress any key to exit..." -ForegroundColor Gray
    $null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
    exit 1
}

# Enable Windows Update for Winget
Enable-WindowsUpdate

Write-Host "`n[1] Update All Software"
Write-Host "[2] Update Selected Software"
Write-Host "[3] Show Installed Software"
Write-Host "[4] Search Software"
Write-Host "[0] Return to Main Menu"

Write-Host "`nSelect option (0-4): " -ForegroundColor Yellow -NoNewline
$choice = Read-Host

switch ($choice) {
    '1' {
        Update-AllSoftware
    }
    '2' {
        Update-SelectedSoftware
    }
    '3' {
        Show-InstalledSoftware
    }
    '4' {
        Search-Software
    }
    '0' {
        Write-Host "`nReturning to main menu..." -ForegroundColor Green
    }
    default {
        Write-Host "`nInvalid selection!" -ForegroundColor Red
    }
}

Write-Host "`nPress any key to continue..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
