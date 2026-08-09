#!/usr/bin/env pwsh

$ErrorActionPreference = "Stop"

# Vai nella root del progetto
Set-Location $PSScriptRoot

Write-Host ""
Write-Host "===================================" -ForegroundColor Cyan
Write-Host " SerialXTemplate Launcher" -ForegroundColor Cyan
Write-Host "===================================" -ForegroundColor Cyan
Write-Host ""

# Verifica virtual environment
$venvActivate = ".venv\Scripts\Activate.ps1"

if (-not (Test-Path $venvActivate)) {
    Write-Host "Virtual environment non trovato." -ForegroundColor Red
    exit 1
}

# Attiva venv
& $venvActivate

$env:PYTHONUTF8 = "1"

Write-Host "Avvio applicazione..." -ForegroundColor Green
Write-Host ""

try {
    python -m src.app.main
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