#!/usr/bin/env pwsh

$ErrorActionPreference = "Stop"

Set-Location $PSScriptRoot

Write-Host ""
Write-Host "===================================" -ForegroundColor Cyan
Write-Host " SerialXTemplate Build" -ForegroundColor Cyan
Write-Host "===================================" -ForegroundColor Cyan
Write-Host ""

# Separatore per --add-data: ';' su Windows, ':' su Linux/macOS
if ($IsWindows -or $null -eq $IsWindows) {
    $sep = ";"
}
else {
    $sep = ":"
}

Write-Host "Avvio build con PyInstaller..." -ForegroundColor Green
Write-Host ""

pyinstaller `
    --noconsole `
    --onefile `
    --name "SerialXTemplate" `
    --add-data "qml${sep}qml" `
    --add-data "assets${sep}assets" `
    main.py

if ($LASTEXITCODE -ne 0) {
    Write-Host ""
    Write-Host "Build fallita." -ForegroundColor Red
    exit $LASTEXITCODE
}

# Pulizia file temporanei generati da PyInstaller
if (Test-Path "SerialXTemplate.spec") {
    Remove-Item "SerialXTemplate.spec" -ErrorAction SilentlyContinue
}

if (Test-Path "build") {
    Remove-Item "build" -Recurse -Force -ErrorAction SilentlyContinue
}

Write-Host ""
Write-Host "Build completata. Eseguibile in dist/" -ForegroundColor Green
