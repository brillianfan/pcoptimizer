# Remove-BrokenShortcuts.ps1
# Script to find and delete shortcuts that point to non-existent files or folders.

$WshShell = New-Object -ComObject WScript.Shell

# Common locations to search for shortcuts
$SearchPaths = @(
    [Environment]::GetFolderPath("Desktop"),
    [Environment]::GetFolderPath("CommonDesktopDirectory"),
    [Environment]::GetFolderPath("StartMenu"),
    [Environment]::GetFolderPath("CommonStartMenu"),
    [Environment]::GetFolderPath("Programs"),
    [Environment]::GetFolderPath("CommonPrograms"),
    [Environment]::GetFolderPath("Recent"),
    [Environment]::GetFolderPath("ApplicationData") + "\Microsoft\Internet Explorer\Quick Launch",
    [Environment]::GetFolderPath("ApplicationData") + "\Microsoft\Internet Explorer\Quick Launch\User Pinned\TaskBar"
)

Write-Host "--- DANG QUET SHORTCUTS LOI ---" -ForegroundColor Cyan

$count = 0

foreach ($Path in $SearchPaths) {
    if (Test-Path $Path) {
        Write-Host "Dang quet: $Path" -ForegroundColor Gray
        
        # Get all .lnk and .url files
        $Shortcuts = Get-ChildItem -Path $Path -Include *.lnk, *.url -Recurse -ErrorAction SilentlyContinue
        
        foreach ($Shortcut in $Shortcuts) {
            $TargetPath = ""
            
            if ($Shortcut.Extension -eq ".lnk") {
                try {
                    $Link = $WshShell.CreateShortcut($Shortcut.FullName)
                    $TargetPath = $Link.TargetPath
                }
                catch {
                    continue
                }
            }
            elseif ($Shortcut.Extension -eq ".url") {
                try {
                    $Content = Get-Content $Shortcut.FullName -ErrorAction SilentlyContinue
                    foreach ($Line in $Content) {
                        if ($Line -like "URL=*") {
                            $TargetPath = $Line.Substring(4)
                            break
                        }
                    }
                }
                catch {
                    continue
                }
            }

            # Check if target exists (only for local paths)
            if ($TargetPath -and $TargetPath.StartsWith("C:") -or $TargetPath.StartsWith("\\")) {
                if (-not (Test-Path $TargetPath)) {
                    Write-Host "[LOI] Target missing: $($Shortcut.Name) -> $TargetPath" -ForegroundColor Red
                    try {
                        Remove-Item $Shortcut.FullName -Force -ErrorAction Stop
                        Write-Host "      -> Da xoa!" -ForegroundColor Yellow
                        $count++
                    }
                    catch {
                        Write-Host "      -> KHONG THE XOA!" -ForegroundColor DarkRed
                    }
                }
            }
        }
    }
}

Write-Host ""
Write-Host "--- HOAN TAT ---" -ForegroundColor Green
Write-Host "Da xoa tong cong $count shortcuts loi." -ForegroundColor Green
