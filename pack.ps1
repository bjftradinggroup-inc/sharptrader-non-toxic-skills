# Builds the upload files in dist\ (not kept in git):
#   dist\sharptrader-non-toxic-plugin.zip  - every skill as one plugin: .claude-plugin/plugin.json + skills/<skill>/SKILL.md
#   dist\<skill>.zip                       - one skill each: <skill>/SKILL.md, the layout skill uploads expect
# Only the skill folders and the manifest are packed: docs\ and README.md are for people, not for the agent.
# Entry names use "/" (Compress-Archive in Windows PowerShell 5.1 writes "\", which other unzip code may refuse).
# Run: powershell -ExecutionPolicy Bypass -File pack.ps1
$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.IO.Compression
Add-Type -AssemblyName System.IO.Compression.FileSystem

$root = $PSScriptRoot
$dist = Join-Path $root 'dist'
if (Test-Path $dist) { Remove-Item $dist -Recurse -Force }
New-Item -ItemType Directory -Path $dist | Out-Null

$skills = Get-ChildItem -Path (Join-Path $root 'skills') -Directory | Where-Object { Test-Path (Join-Path $_.FullName 'SKILL.md') }
if (-not $skills) { throw 'No skills\<skill>\SKILL.md found.' }

function Add-Folder($zip, $folder, $prefix) {
    foreach ($file in Get-ChildItem -Path $folder -Recurse -File) {
        $relative = $file.FullName.Substring($folder.Length + 1) -replace '\\', '/'
        [System.IO.Compression.ZipFileExtensions]::CreateEntryFromFile($zip, $file.FullName, $prefix + $relative, [System.IO.Compression.CompressionLevel]::Optimal) | Out-Null
    }
}

function New-Zip($target, [scriptblock]$fill) {
    $zip = [System.IO.Compression.ZipFile]::Open($target, [System.IO.Compression.ZipArchiveMode]::Create)
    try { & $fill $zip } finally { $zip.Dispose() }
    Write-Output "$target ($((Get-Item $target).Length) bytes)"
}

# the plugin: every skill in one upload
New-Zip (Join-Path $dist 'sharptrader-non-toxic-plugin.zip') {
    param($zip)
    [System.IO.Compression.ZipFileExtensions]::CreateEntryFromFile($zip, (Join-Path $root '.claude-plugin\plugin.json'), '.claude-plugin/plugin.json', [System.IO.Compression.CompressionLevel]::Optimal) | Out-Null
    foreach ($skill in $skills) { Add-Folder $zip $skill.FullName ('skills/' + $skill.Name + '/') }
}

# one zip per skill
foreach ($skill in $skills) {
    New-Zip (Join-Path $dist ($skill.Name + '.zip')) {
        param($zip)
        Add-Folder $zip $skill.FullName ($skill.Name + '/')
    }
}
