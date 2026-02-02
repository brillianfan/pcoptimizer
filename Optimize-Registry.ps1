<#
.SYNOPSIS
    Optimize-Registry.ps1 - Windows Registry optimization module
.DESCRIPTION
    Optimizes Windows Registry for better system responsiveness
.VERSION
    1.0.2
.AUTHOR
    Brillian Pham (pcoptimizer.seventy907@slmail.me)
#>

function Set-RegistryValue {
    param(
        [string]$Path,
        [string]$Name,
        [string]$Value,
        [string]$Type = 'String',
        [string]$Description
    )
    
    try {
        # Create key if it doesn't exist
        if (-not (Test-Path $Path)) {
            New-Item -Path $Path -Force | Out-Null
        }
        
        # Set value based on type
        switch ($Type) {
            'String' {
                Set-ItemProperty -Path $Path -Name $Name -Value $Value -Type String -Force
            }
            'DWord' {
                Set-ItemProperty -Path $Path -Name $Name -Value ([int]$Value) -Type DWord -Force
            }
        }
        
        Write-Host "[OK] $Description" -ForegroundColor Green
        return $true
    }
    catch {
        Write-Host "[ERROR] Failed to set $Description : $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

function Optimize-SystemResponsiveness {
    Write-Host "`n======================================================"
    Write-Host "         OPTIMIZING SYSTEM RESPONSIVENESS"
    Write-Host "======================================================`n"
    
    $optimizations = @(
        @{
            Path        = 'HKCU:\Control Panel\Desktop'
            Name        = 'WaitToKillAppTimeout'
            Value       = '2000'
            Type        = 'String'
            Description = 'Reduce app close timeout (20s -> 2s)'
        },
        @{
            Path        = 'HKCU:\Control Panel\Desktop'
            Name        = 'MenuShowDelay'
            Value       = '0'
            Type        = 'String'
            Description = 'Remove menu delay (400ms -> 0ms)'
        },
        @{
            Path        = 'HKCU:\Control Panel\Desktop'
            Name        = 'AutoEndTasks'
            Value       = '1'
            Type        = 'String'
            Description = 'Auto-close unresponsive apps on shutdown'
        },
        @{
            Path        = 'HKCU:\Control Panel\Mouse'
            Name        = 'MouseHoverTime'
            Value       = '10'
            Type        = 'String'
            Description = 'Increase mouse/keyboard responsiveness'
        },
        @{
            Path        = 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile'
            Name        = 'NetworkThrottlingIndex'
            Value       = '4294967295'
            Type        = 'DWord'
            Description = 'Optimize network throttling'
        },
        @{
            Path        = 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile'
            Name        = 'SystemResponsiveness'
            Value       = '0'
            Type        = 'DWord'
            Description = 'Maximize system responsiveness'
        }
    )
    
    $successCount = 0
    $totalCount = $optimizations.Count
    
    foreach ($opt in $optimizations) {
        if (Set-RegistryValue @opt) {
            $successCount++
        }
        Start-Sleep -Milliseconds 200
    }
    
    Write-Host "`n======================================================" -ForegroundColor Cyan
    Write-Host "         OPTIMIZATION SUMMARY" -ForegroundColor Cyan
    Write-Host "======================================================`n" -ForegroundColor Cyan
    
    Write-Host "Successfully applied: $successCount / $totalCount optimizations" -ForegroundColor Green
    
    if ($successCount -eq $totalCount) {
        Write-Host "`n[SUCCESS] All registry optimizations applied!" -ForegroundColor Green
    }
    else {
        Write-Host "`n[WARNING] Some optimizations failed. Run as Administrator." -ForegroundColor Yellow
    }
    
    Write-Host "`n[NOTE] Please restart your computer for changes to take full effect.`n" -ForegroundColor Yellow
}

function Show-CurrentSettings {
    Write-Host "`n======================================================"
    Write-Host "         CURRENT REGISTRY SETTINGS"
    Write-Host "======================================================`n"
    
    $settings = @(
        @{
            Path        = 'HKCU:\Control Panel\Desktop'
            Name        = 'WaitToKillAppTimeout'
            Description = 'App Close Timeout'
            Default     = '20000'
            Optimal     = '2000'
        },
        @{
            Path        = 'HKCU:\Control Panel\Desktop'
            Name        = 'MenuShowDelay'
            Description = 'Menu Show Delay'
            Default     = '400'
            Optimal     = '0'
        },
        @{
            Path        = 'HKCU:\Control Panel\Desktop'
            Name        = 'AutoEndTasks'
            Description = 'Auto End Tasks'
            Default     = '0'
            Optimal     = '1'
        }
    )
    
    foreach ($setting in $settings) {
        try {
            $currentValue = Get-ItemProperty -Path $setting.Path -Name $setting.Name -ErrorAction SilentlyContinue |
            Select-Object -ExpandProperty $setting.Name
            
            $status = if ($currentValue -eq $setting.Optimal) {
                "[OPTIMIZED]"
                $color = "Green"
            }
            else {
                "[NOT OPTIMIZED]"
                $color = "Yellow"
            }
            
            Write-Host "$($setting.Description): " -NoNewline
            Write-Host "$status " -ForegroundColor $color -NoNewline
            Write-Host "Current: $currentValue, Optimal: $($setting.Optimal)"
        }
        catch {
            Write-Host "$($setting.Description): [NOT SET]" -ForegroundColor Red
        }
    }
    
    Write-Host ""
}

function Backup-RegistrySettings {
    Write-Host "`n======================================================"
    Write-Host "         CREATING REGISTRY BACKUP"
    Write-Host "======================================================`n"
    
    $backupPath = Join-Path $env:USERPROFILE "Desktop\Registry_Backup_$(Get-Date -Format 'yyyyMMdd_HHmmss').reg"
    
    try {
        $keys = @(
            'HKCU\Control Panel\Desktop',
            'HKCU\Control Panel\Mouse',
            'HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile'
        )
        
        foreach ($key in $keys) {
            reg export $key $backupPath /y 2>$null | Out-Null
        }
        
        if (Test-Path $backupPath) {
            Write-Host "[OK] Registry backup created: $backupPath" -ForegroundColor Green
            return $true
        }
        else {
            Write-Host "[WARNING] Could not create backup" -ForegroundColor Yellow
            return $false
        }
    }
    catch {
        Write-Host "[ERROR] Backup failed: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

# Main execution
Write-Host "======================================================"
Write-Host "         REGISTRY OPTIMIZATION MODULE"
Write-Host "======================================================"

Write-Host "`n[1] Show current registry settings"
Write-Host "[2] Create registry backup"
Write-Host "[3] Optimize registry settings"
Write-Host "[4] Optimize ALL (backup + optimize)"
Write-Host "[0] Cancel"

Write-Host "`nSelect option (0-4): " -ForegroundColor Yellow -NoNewline
$choice = Read-Host

switch ($choice) {
    '1' {
        Show-CurrentSettings
    }
    '2' {
        Backup-RegistrySettings
    }
    '3' {
        Write-Host "`nThis will modify Windows Registry settings." -ForegroundColor Yellow
        Write-Host "Continue? (Y/N): " -ForegroundColor Yellow -NoNewline
        $confirm = Read-Host
        
        if ($confirm -eq 'Y' -or $confirm -eq 'y') {
            Optimize-SystemResponsiveness
        }
        else {
            Write-Host "`nOptimization cancelled." -ForegroundColor Yellow
        }
    }
    '4' {
        Write-Host "`nThis will backup current settings and optimize registry." -ForegroundColor Yellow
        Write-Host "Continue? (Y/N): " -ForegroundColor Yellow -NoNewline
        $confirm = Read-Host
        
        if ($confirm -eq 'Y' -or $confirm -eq 'y') {
            if (Backup-RegistrySettings) {
                Optimize-SystemResponsiveness
            }
            else {
                Write-Host "`nOptimization cancelled due to backup failure." -ForegroundColor Red
            }
        }
        else {
            Write-Host "`nOptimization cancelled." -ForegroundColor Yellow
        }
    }
    '0' {
        Write-Host "`nCancelled." -ForegroundColor Yellow
    }
    default {
        Write-Host "`nInvalid selection!" -ForegroundColor Red
    }
}
