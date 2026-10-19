# Nuovo script PowerShell per aggiornare il template SerialX con i file locali personalizzati.
# PER MANTEINER DI PROGETTI CHE USANO QUESTO TEMPLATE

# TODO:
# creare una copia di backup .zip della dir ../
# scaricare il template da github nei file temporanei
# estrai il contenuto nei file temporanei
# copia i file da firmware/ locale alla firmware/ temporanea
# copia i file da dashboard/docs/* locale alla dashboard/docs/* temporanea
# copia i file da dashboard/assets/* locale alla dashboard/assets/* temporanea
# copia i file da dashboard/helpers/* locale alla dashboard/helpers/* temporanea
# copia i file da dashboard/qml/components/customs/* locale alla dashboard/qml/components/customs/* temporanea
# copia il file dashboard/qml/views/CustomView.qml locale alla dashboard/qml/views/CustomView.qml temporanea
# copia il file dashboard/viewmodels/custom_viewmodel.py locale alla dashboard/viewmodels/custom_viewmodel.py temporanea
# copia il file dashboard/app.py locale alla dashboard/app.py temporanea
# copia il file dashboard/requirements.custom.txt locale alla dashboard/requirements.custom.txt temporanea  
# copia tutti i file in .github/workflows/ locale in .github/workflows/ temporanea (non sovrascrivere i file esistenti se hanno lo stesso nome, tieni quelli temporanei)

$ErrorActionPreference = "Stop"

# Parametri del repository
$repoUrl = "https://github.com/SerialXProject/serialx-template"
$branch  = "main"

# Percorsi
$scriptDir = if ($PSScriptRoot) { $PSScriptRoot } else { (Get-Location).Path }
$localRoot = (Resolve-Path (Join-Path $scriptDir "..")).Path
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$tempBase  = Join-Path $env:TEMP "serialx_update_$timestamp"
$zipFile   = Join-Path $tempBase "template.zip"
$extractTmp = Join-Path $tempBase "extract"

Write-Host "=== Aggiornamento template SerialX ===" -ForegroundColor Cyan
Write-Host "Radice progetto locale: $localRoot" -ForegroundColor Gray

# ---------------------------------------------------------------
# Funzioni di supporto
# ---------------------------------------------------------------
function Copy-DirContents {
    param([string]$RelativePath)
    $src = Join-Path $localRoot $RelativePath
    $dst = Join-Path $template  $RelativePath

    if (-not (Test-Path $src)) {
        Write-Host "  [salto] Non trovato in locale: $RelativePath" -ForegroundColor DarkYellow
        return
    }
    New-Item -ItemType Directory -Force -Path $dst | Out-Null
    Copy-Item -Path (Join-Path $src "*") -Destination $dst -Recurse -Force
    Write-Host "  [ok] $RelativePath/*" -ForegroundColor Green
}

function Copy-SingleFile {
    param([string]$RelativePath)
    $src = Join-Path $localRoot $RelativePath
    $dst = Join-Path $template  $RelativePath

    if (-not (Test-Path $src -PathType Leaf)) {
        Write-Host "  [salto] Non trovato in locale: $RelativePath" -ForegroundColor DarkYellow
        return
    }
    New-Item -ItemType Directory -Force -Path (Split-Path $dst -Parent) | Out-Null
    Copy-Item -Path $src -Destination $dst -Force
    Write-Host "  [ok] $RelativePath" -ForegroundColor Green
}

function Copy-NoOverwrite {
    param([string]$RelativePath)
    $src = Join-Path $localRoot $RelativePath
    $dst = Join-Path $template  $RelativePath

    if (-not (Test-Path $src)) {
        Write-Host "  [salto] Non trovato in locale: $RelativePath" -ForegroundColor DarkYellow
        return
    }
    New-Item -ItemType Directory -Force -Path $dst | Out-Null

    Get-ChildItem -Path $src -Recurse -File -Force | ForEach-Object {
        $rel    = $_.FullName.Substring($src.Length).TrimStart('\', '/')
        $target = Join-Path $dst $rel
        if (Test-Path $target) {
            Write-Host "  [mantengo template] $RelativePath/$rel" -ForegroundColor DarkYellow
        } else {
            New-Item -ItemType Directory -Force -Path (Split-Path $target -Parent) | Out-Null
            Copy-Item -Path $_.FullName -Destination $target
            Write-Host "  [ok] $RelativePath/$rel" -ForegroundColor Green
        }
    }
}

# ---------------------------------------------------------------
# 1. Backup .zip della dir ../
# ---------------------------------------------------------------
$backupZip = Join-Path (Split-Path $localRoot -Parent) ("{0}_backup_{1}.zip" -f (Split-Path $localRoot -Leaf), $timestamp)
Write-Host "`n[1/4] Creazione backup: $backupZip" -ForegroundColor Yellow
try {
    Compress-Archive -Path $localRoot -DestinationPath $backupZip -CompressionLevel Optimal
} catch {
    Write-Host "Errore durante la creazione del backup: $_" -ForegroundColor Red
    exit 1
}

# ---------------------------------------------------------------
# 2. Download del template nei file temporanei
# ---------------------------------------------------------------
Write-Host "`n[2/4] Download del template..." -ForegroundColor Yellow
New-Item -ItemType Directory -Force -Path $tempBase | Out-Null
$zipUrl = "$repoUrl/archive/refs/heads/$branch.zip"
try {
    Invoke-WebRequest -Uri $zipUrl -OutFile $zipFile
} catch {
    Write-Host "Errore durante il download del repository: $_" -ForegroundColor Red
    exit 1
}

# ---------------------------------------------------------------
# 3. Estrazione nei file temporanei
# ---------------------------------------------------------------
Write-Host "`n[3/4] Estrazione dei file..." -ForegroundColor Yellow
try {
    Expand-Archive -Path $zipFile -DestinationPath $extractTmp -Force
} catch {
    Write-Host "Errore durante l'estrazione dello zip: $_" -ForegroundColor Red
    exit 1
}
$template = (Get-ChildItem -Path $extractTmp -Directory | Select-Object -First 1).FullName
Remove-Item $zipFile -Force

# ---------------------------------------------------------------
# 4. Copia dei file locali nel template temporaneo
# ---------------------------------------------------------------
Write-Host "`n[4/4] Copia dei file locali nel template temporaneo..." -ForegroundColor Yellow

# Cartelle (contenuto)
Copy-DirContents "firmware"
Copy-DirContents "dashboard/docs"
Copy-DirContents "dashboard/assets"
Copy-DirContents "dashboard/helpers"
Copy-DirContents "dashboard/qml/components/customs"

# File singoli
Copy-SingleFile "dashboard/qml/views/CustomView.qml"
Copy-SingleFile "dashboard/viewmodels/custom_viewmodel.py"
Copy-SingleFile "dashboard/app.py"
Copy-SingleFile "dashboard/requirements.custom.txt"

# Workflows: non sovrascrivere i file con lo stesso nome (vince il template)
Copy-NoOverwrite ".github/workflows"

# ---------------------------------------------------------------
Write-Host "`nOperazione completata." -ForegroundColor Cyan
Write-Host "Backup:             $backupZip" -ForegroundColor Green
Write-Host "Template aggiornato: $template" -ForegroundColor Green