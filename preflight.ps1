# preflight.ps1 - Fast code check before push
$errors = @()

Write-Host "`n========================================"
Write-Host "  Preflight Check"
Write-Host "========================================`n"

# 1. Check critical files
Write-Host "[1/2] Checking critical files..."
$criticalFiles = @(
    "lib\main.dart",
    "lib\app.dart",
    "pubspec.yaml",
    "android\app\src\main\AndroidManifest.xml",
    "assets\config\sources.json",
    "assets\config\tone_rules.json"
)

foreach ($f in $criticalFiles) {
    if (-not (Test-Path $f)) {
        $errors += "MISSING: $f"
    }
}

if ($errors.Count -eq 0) {
    Write-Host "  PASS`n"
}

# 2. Check all import paths
Write-Host "[2/2] Checking import paths..."

Get-ChildItem -Path "lib" -Recurse -Filter "*.dart" | ForEach-Object {
    $file = $_.FullName
    $dir = $_.DirectoryName
    $content = Get-Content $file -Raw
    
    $matches = [regex]::Matches($content, "import '([^']+)'")
    
    foreach ($m in $matches) {
        $importPath = $m.Groups[1].Value
        
        if ($importPath -match "^package:" -or $importPath -match "^dart:" -or $importPath -match "^http") {
            continue
        }
        
        $fullPath = Join-Path $dir $importPath
        $fullPath = $fullPath.Replace('/', '\')
        
        if (-not (Test-Path $fullPath)) {
            $shortFile = $file.Replace((Get-Location).Path + "\", "")
            $errors += "$shortFile : import '$importPath' -> NOT FOUND"
        }
    }
}

# Output results
Write-Host "`n========================================"
if ($errors.Count -gt 0) {
    Write-Host "  FAIL: $($errors.Count) errors"
    Write-Host "========================================`n"
    $errors | ForEach-Object { Write-Host "  [X] $_" }
    Write-Host "`nFix before push!`n"
    exit 1
} else {
    Write-Host "  PASS: All checks passed"
    Write-Host "========================================`n"
    exit 0
}
