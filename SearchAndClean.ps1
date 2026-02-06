cls
$appName = Read-Host "Enter application name to search"

Write-Host "`n=== Searching for: $appName ===" -ForegroundColor Yellow

$searchLocations = @{
    "Program Files" = "C:\Program Files"
    "Program Files (x86)" = "C:\Program Files (x86)"
    "AppData Roaming" = "$env:APPDATA"
    "AppData Local" = "$env:LOCALAPPDATA"
    "AppData LocalLow" = "$env:USERPROFILE\AppData\LocalLow"
    "ProgramData" = "C:\ProgramData"
    "User Documents" = "$env:USERPROFILE\Documents"
    "Desktop" = "$env:USERPROFILE\Desktop"
    "Start Menu" = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs"
    "Common Start Menu" = "C:\ProgramData\Microsoft\Windows\Start Menu\Programs"
    "Temp" = "$env:TEMP"
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

# Tìm trong Registry
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

# Tùy chọn xóa
if ($foundItems.Count -gt 0) {
    $delete = Read-Host "`nDo you want to delete all found items? (Type YES to confirm)"
    
    if ($delete -eq "YES") {
        foreach ($item in $foundItems) {
            if ($item -like "Registry:*") {
                $regKey = $item -replace "Registry: ", ""
                Write-Host "Deleting registry: $regKey" -ForegroundColor Red
                reg delete $regKey /f 2>$null
            } else {
                Write-Host "Deleting: $item" -ForegroundColor Red
                Remove-Item -Path $item -Recurse -Force -ErrorAction SilentlyContinue
            }
        }
        Write-Host "`nCleanup completed!" -ForegroundColor Green
    }
}