#!/usr/bin/env pwsh

$ErrorActionPreference = "Stop"

# Vai nella root del progetto
Set-Location $PSScriptRoot

Write-Host ""
Write-Host "===================================" -ForegroundColor Cyan
Write-Host " SerialXTemplate Launcher" -ForegroundColor Cyan
Write-Host "===================================" -ForegroundColor Cyan
Write-Host ""

# Determina il path di attivazione del venv in base al sistema operativo
if ($IsWindows -or $null -eq $IsWindows) {
    $venvActivate = Join-Path ".venv" "Scripts" "Activate.ps1"
    $pythonBin = Join-Path ".venv" "Scripts" "python.exe"
}
else {
    $venvActivate = Join-Path ".venv" "bin" "Activate.ps1"
    $pythonBin = Join-Path ".venv" "bin" "python"
}

if (-not (Test-Path $venvActivate)) {
    Write-Host "Virtual environment non trovato in .venv" -ForegroundColor Red
    Write-Host "Crealo con: python -m venv .venv" -ForegroundColor Yellow
    exit 1
}

# Attiva venv
& $venvActivate

$env:PYTHONUTF8 = "1"

Write-Host "Avvio applicazione..." -ForegroundColor Green
Write-Host ""

try {
    python -m main
}
catch {
    Write-Host ""
    Write-Host "Errore durante l'avvio:" -ForegroundColor Red
    Write-Host $_
}
finally {
    if ($IsWindows -or $null -eq $IsWindows) {
        Write-Host ""
        Read-Host "Premi Enter per chiudere"
    }
}