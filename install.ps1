# UltraBuilder installer for Windows PowerShell

$SkillsDir = "$env:USERPROFILE\.claude\skills"

Write-Host "Installing UltraBuilder skills to: $SkillsDir" -ForegroundColor Cyan
Write-Host ""

# Create skills directory if it doesn't exist
if (-not (Test-Path $SkillsDir)) {
    New-Item -ItemType Directory -Path $SkillsDir -Force | Out-Null
}

# Copy each skill
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$SkillsSrc = Join-Path $ScriptDir "skills"

$count = 0
Get-ChildItem -Path $SkillsSrc -Directory | ForEach-Object {
    $skillName = $_.Name
    $destDir = Join-Path $SkillsDir $skillName

    if (-not (Test-Path $destDir)) {
        New-Item -ItemType Directory -Path $destDir -Force | Out-Null
    }

    Copy-Item -Path (Join-Path $_.FullName "SKILL.md") -Destination (Join-Path $destDir "SKILL.md") -Force
    $count++
    Write-Host "  Installed: /$skillName" -ForegroundColor Green
}

Write-Host ""
Write-Host "Done! Installed $count skills." -ForegroundColor Cyan
Write-Host ""
Write-Host "Usage:"
Write-Host "  /ultrabuilder       - Full pipeline"
Write-Host "  /office-hours       - Challenge your idea"
Write-Host "  /build-execute      - Jump to implementation"
Write-Host "  /investigate        - Debug systematically"
Write-Host "  /health             - Check code quality"
Write-Host ""
Write-Host "See README.md for full documentation."
