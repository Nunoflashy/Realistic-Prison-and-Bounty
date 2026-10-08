# Builds a runnable RPB package (no sources) from any commit, branch or tag, for a VM or a clean install.
#
#   .\build-vm-package.ps1                         # the current HEAD
#   .\build-vm-package.ps1 -Ref v0.16.3-load-freeze
#   .\build-vm-package.ps1 -Ref arrest-start-fixes -OutDir "E:\VM share"
#
# It extracts that commit into a temp folder, applies the local RPB_StorageVars tweak (the silenced per-write debug line,
# so the log volume matches the dev install), compiles every script with pyro, and zips the plugin, the compiled scripts,
# the dev-menu bindings, Seq, RPB_Data (that commit's JSON plus the current mcm.json) and LICENSE.
param(
    [string]$Ref = "HEAD",
    [string]$OutDir = "D:\Games\Modded Skyrim SE\RPB VM builds",
    [string]$GamePath = "D:\Games\Modded Skyrim SE\Skyrim Special Edition"
)
$ErrorActionPreference = "Stop"
$repo = $PSScriptRoot

# pyro from the newest installed Papyrus extension
$extension = Get-ChildItem "$env:USERPROFILE\.vscode\extensions" -Directory -Filter "joelday.papyrus-lang-vscode-*" |
    Sort-Object Name -Descending | Select-Object -First 1
if (-not $extension) { throw "The Papyrus VS Code extension (pyro) was not found" }
$pyro = Join-Path $extension.FullName "pyro\pyro.exe"

$short = (git -C $repo rev-parse --short $Ref).Trim()
if ($LASTEXITCODE -ne 0) { throw "Unknown ref: $Ref" }
$label = if ($Ref -eq "HEAD") { (git -C $repo rev-parse --abbrev-ref HEAD).Trim() } else { $Ref }
$name = "RPB $label $short"
$work = Join-Path $env:TEMP "rpb-vm-build-$short"
$src = Join-Path $work "src"
$pkg = Join-Path $work "pkg"
if (Test-Path $work) { Remove-Item $work -Recurse -Force -Confirm:$false }
New-Item -ItemType Directory -Force $src, $pkg | Out-Null

Write-Host "Extracting $Ref ($short)..."
$zip = Join-Path $work "src.zip"
git -C $repo archive --format=zip -o $zip $Ref
if ($LASTEXITCODE -ne 0) { throw "git archive failed" }
Expand-Archive $zip -DestinationPath $src

$patch = Join-Path $work "storagevars.patch"
git -C $repo diff -- Scripts/source/RPB_StorageVars.psc | Out-File -Encoding ascii $patch
if ((Get-Item $patch).Length -gt 0) {
    Push-Location $src
    git apply --whitespace=nowarn $patch
    if ($LASTEXITCODE -ne 0) { Write-Warning "The local RPB_StorageVars tweak didn't apply to ${Ref}: built without it" }
    Pop-Location
}

Write-Host "Compiling with $pyro..."
Push-Location $src
& $pyro -g sse --game-path $GamePath skyrimse.ppj
Pop-Location
$sources = (Get-ChildItem (Join-Path $src "Scripts\Source") -Filter *.psc).Count
$compiled = (Get-ChildItem (Join-Path $src "Scripts") -Filter *.pex).Count
if ($compiled -lt $sources) { throw "Only $compiled of $sources scripts compiled" }

Write-Host "Assembling..."
New-Item -ItemType Directory -Force (Join-Path $pkg "Scripts\AutoBindings"), (Join-Path $pkg "Seq"), (Join-Path $pkg "RPB_Data\Presets") | Out-Null
Copy-Item (Join-Path $src "RealisticPrisonAndBounty.esp"), (Join-Path $src "LICENSE") $pkg
Copy-Item (Join-Path $src "Seq\RealisticPrisonAndBounty.seq") (Join-Path $pkg "Seq")
Copy-Item (Join-Path $src "Scripts\*.pex") (Join-Path $pkg "Scripts")
Copy-Item (Join-Path $src "Scripts\AutoBindings\RPB_AutoBindings.txt") (Join-Path $pkg "Scripts\AutoBindings")
Copy-Item (Join-Path $src "RPB_Data\*.json") (Join-Path $pkg "RPB_Data")
Copy-Item (Join-Path $repo "RPB_Data\mcm.json") (Join-Path $pkg "RPB_Data")

New-Item -ItemType Directory -Force $OutDir | Out-Null
$out = Join-Path $OutDir "$name.zip"
Compress-Archive -Path (Join-Path $pkg "*") -DestinationPath $out -Force
Remove-Item $work -Recurse -Force -Confirm:$false
Write-Host "Done: $out ($compiled scripts)"
