param([string]$ZipPath = (Join-Path $PSScriptRoot 'Steven_Lim_FullStack_Portfolio_V1.zip'))
$ErrorActionPreference = 'Stop'
$repo = 'https://github.com/SteRika/Steven-Lim-Portofolio-2026.git'
if (-not (Get-Command git -ErrorAction SilentlyContinue)) { throw 'Git for Windows is required.' }
if (-not (Test-Path -LiteralPath $ZipPath)) { throw "ZIP not found: $ZipPath" }
$work = Join-Path $env:TEMP ('StevenPortfolio_' + [Guid]::NewGuid().ToString('N'))
$extract = Join-Path $work 'extracted'
$checkout = Join-Path $work 'repo'
New-Item -ItemType Directory -Force -Path $extract | Out-Null
Expand-Archive -LiteralPath $ZipPath -DestinationPath $extract -Force
$source = Join-Path $extract 'steven-portfolio-v1'
if (-not (Test-Path (Join-Path $source 'frontend/package.json'))) { throw 'ZIP structure is unexpected.' }
& git clone --branch main $repo $checkout
if ($LASTEXITCODE -ne 0) { throw 'Git clone failed; check your GitHub authentication and internet connection.' }
Get-ChildItem -LiteralPath $source -Force | ForEach-Object {
    Copy-Item -LiteralPath $_.FullName -Destination $checkout -Force -Recurse
}
& git -C $checkout add -A
if ($LASTEXITCODE -ne 0) { throw 'Git add failed.' }
& git -C $checkout diff --cached --quiet
if ($LASTEXITCODE -eq 0) { Write-Host 'Everything is already uploaded.'; exit 0 }
& git -C $checkout commit -m 'Add full-stack portfolio source'
if ($LASTEXITCODE -ne 0) { throw 'Set your global Git user.name and user.email, then retry.' }
& git -C $checkout push origin main
if ($LASTEXITCODE -ne 0) { throw "Push failed. Local checkout preserved in $checkout" }
Write-Host 'Portfolio uploaded: https://github.com/SteRika/Steven-Lim-Portofolio-2026'
