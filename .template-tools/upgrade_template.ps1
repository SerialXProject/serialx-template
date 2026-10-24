# Nuovo script PowerShell per aggiornare il template SerialX con i file locali personalizzati.
# PER MANTEINER DI PROGETTI CHE USANO QUESTO TEMPLATE

# TODO:
# creare una copia di backup .zip della dir ../
# scaricare il template da github nei file temporanei
# estrai il contenuto nei file temporanei
# copia i file da firmware/ locale alla firmware/ temporanea
# copia i file da dashboard/docs/* locale alla dashboard/docs/* temporanea
# copia i file da dashboard/assets/* locale alla dashboard/assets/* temporanea
# copia i file da dashboard/helpers/* locale alla dashboard/helpers/* temporanea // TODO: escludi updates.py e logger.py
# copia i file da dashboard/qml/components/customs/* locale alla dashboard/qml/components/customs/* temporanea
# copia il file dashboard/qml/views/CustomView.qml locale alla dashboard/qml/views/CustomView.qml temporanea
# copia il file dashboard/viewmodels/custom_viewmodel.py locale alla dashboard/viewmodels/custom_viewmodel.py temporanea
# copia il file dashboard/app.py locale alla dashboard/app.py temporanea
# copia il file dashboard/requirements.custom.txt locale alla dashboard/requirements.custom.txt temporanea  
# copia tutti i file in .github/workflows/ locale in .github/workflows/ temporanea (non sovrascrivere i file esistenti se hanno lo stesso nome, tieni quelli temporanei)

$ErrorActionPreference = "Stop"
try { [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 } catch {}

# Parametri del repository
$repoUrl = "https://github.com/SerialXProject/serialx-template"
$branch  = "main"

# Percorsi
$scriptDir  = if ($PSScriptRoot) { $PSScriptRoot } else { (Get-Location).Path }
$localRoot  = (Resolve-Path (Join-Path $scriptDir "..")).Path
$timestamp  = Get-Date -Format "yyyyMMdd_HHmmss"
$tempBase   = Join-Path $env:TEMP "serialx_update_$timestamp"
$zipFile    = Join-Path $tempBase "template.zip"
$extractTmp = Join-Path $tempBase "extract"
$template   = $null   # valorizzato dopo l'estrazione

# Cartelle in cima al progetto escluse dal backup (pesanti e rigenerabili)
$backupExclude = @(".venv", "venv", "__pycache__", "node_modules")

Write-Host "=== Aggiornamento template SerialX ===" -ForegroundColor Cyan
Write-Host "Radice progetto locale: $localRoot" -ForegroundColor Gray

# ---------------------------------------------------------------
# Funzioni di supporto
# ---------------------------------------------------------------

# Copia ricorsivamente il contenuto di una cartella locale nel template.
# -Exclude: percorsi relativi (alla cartella copiata, con '/') da NON copiare.
function Copy-DirContents {
    param(
        [string]$RelativePath,
        [string[]]$Exclude = @()
    )
    $srcRaw = Join-Path $localRoot $RelativePath
    $dst    = Join-Path $template  $RelativePath

    if (-not (Test-Path -LiteralPath $srcRaw -PathType Container)) {
        Write-Host "  [salto] Non trovato in locale: $RelativePath" -ForegroundColor DarkYellow
        return
    }
    $src = (Resolve-Path -LiteralPath $srcRaw).Path
    New-Item -ItemType Directory -Force -Path $dst | Out-Null

    $count = 0
    Get-ChildItem -LiteralPath $src -Recurse -File -Force | ForEach-Object {
        $rel     = $_.FullName.Substring($src.Length).TrimStart('\', '/')
        $relNorm = $rel -replace '\\', '/'

        # Mai copiare la cache di Python
        if ($relNorm -match '(^|/)__pycache__/') { return }

        if ($Exclude -contains $relNorm) {
            Write-Host "  [escluso] $RelativePath/$relNorm (resta quello del template)" -ForegroundColor DarkYellow
            return
        }

        $target = Join-Path $dst $rel
        New-Item -ItemType Directory -Force -Path (Split-Path $target -Parent) | Out-Null
        Copy-Item -LiteralPath $_.FullName -Destination $target -Force
        $count++
    }
    Write-Host "  [ok] $RelativePath/* ($count file)" -ForegroundColor Green
}

# Copia un singolo file locale nel template (sovrascrive).
function Copy-SingleFile {
    param([string]$RelativePath)
    $src = Join-Path $localRoot $RelativePath
    $dst = Join-Path $template  $RelativePath

    if (-not (Test-Path -LiteralPath $src -PathType Leaf)) {
        Write-Host "  [salto] Non trovato in locale: $RelativePath" -ForegroundColor DarkYellow
        return
    }
    New-Item -ItemType Directory -Force -Path (Split-Path $dst -Parent) | Out-Null
    Copy-Item -LiteralPath $src -Destination $dst -Force
    Write-Host "  [ok] $RelativePath" -ForegroundColor Green
}

# Copia i file locali nel template SENZA sovrascrivere quelli gia' presenti (vince il template).
function Copy-NoOverwrite {
    param([string]$RelativePath)
    $srcRaw = Join-Path $localRoot $RelativePath
    $dst    = Join-Path $template  $RelativePath

    if (-not (Test-Path -LiteralPath $srcRaw -PathType Container)) {
        Write-Host "  [salto] Non trovato in locale: $RelativePath" -ForegroundColor DarkYellow
        return
    }
    $src = (Resolve-Path -LiteralPath $srcRaw).Path
    New-Item -ItemType Directory -Force -Path $dst | Out-Null

    Get-ChildItem -LiteralPath $src -Recurse -File -Force | ForEach-Object {
        $rel    = $_.FullName.Substring($src.Length).TrimStart('\', '/')
        $target = Join-Path $dst $rel
        if (Test-Path -LiteralPath $target) {
            Write-Host "  [mantengo template] $RelativePath/$rel" -ForegroundColor DarkYellow
        } else {
            New-Item -ItemType Directory -Force -Path (Split-Path $target -Parent) | Out-Null
            Copy-Item -LiteralPath $_.FullName -Destination $target
            Write-Host "  [ok] $RelativePath/$rel" -ForegroundColor Green
        }
    }
}

# ---------------------------------------------------------------
# 1. Backup .zip della dir ../
# ---------------------------------------------------------------
$backupZip = Join-Path (Split-Path $localRoot -Parent) ("{0}_backup_{1}.zip" -f (Split-Path $localRoot -Leaf), $timestamp)
Write-Host "`n[1/5] Creazione backup: $backupZip" -ForegroundColor Yellow
try {
    Get-ChildItem -LiteralPath $localRoot -Force |
        Where-Object { $backupExclude -notcontains $_.Name } |
        Compress-Archive -DestinationPath $backupZip -CompressionLevel Optimal
} catch {
    Write-Host "Errore durante la creazione del backup: $_" -ForegroundColor Red
    exit 1
}

# ---------------------------------------------------------------
# 2. Download del template nei file temporanei
# ---------------------------------------------------------------
Write-Host "`n[2/5] Download del template..." -ForegroundColor Yellow
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
Write-Host "`n[3/5] Estrazione dei file..." -ForegroundColor Yellow
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
Write-Host "`n[4/5] Copia dei file locali nel template temporaneo..." -ForegroundColor Yellow

# Cartelle (contenuto)
Copy-DirContents "firmware"
Copy-DirContents "dashboard/docs"
Copy-DirContents "dashboard/assets"
Copy-DirContents "dashboard/helpers" -Exclude @("updates.py", "logger.py")   # questi due restano del template
Copy-DirContents "dashboard/qml/components/customs"

# File singoli
Copy-SingleFile "dashboard/qml/views/CustomView.qml"
Copy-SingleFile "dashboard/viewmodels/custom_viewmodel.py"
Copy-SingleFile "dashboard/app.py"
Copy-SingleFile "dashboard/requirements.custom.txt"

# Workflows: non sovrascrivere i file con lo stesso nome (vince il template)
Copy-NoOverwrite ".github/workflows"

# ---------------------------------------------------------------
# 5. Applicazione al progetto locale (con conferma)
# ---------------------------------------------------------------
Write-Host "`n[5/5] Applicazione al progetto locale" -ForegroundColor Yellow
Write-Host "Template aggiornato (temporaneo): $template" -ForegroundColor Gray
Write-Host "Nota: i file presenti solo in locale e non nel template NON vengono eliminati." -ForegroundColor Gray

$answer = Read-Host "Sovrascrivere il progetto in '$localRoot' con il template aggiornato? (s/N)"
if ($answer -match '^[sSyY]') {
    try {
        Get-ChildItem -LiteralPath $template -Force |
            Where-Object { $_.Name -ne ".git" } |
            Copy-Item -Destination $localRoot -Recurse -Force
        Remove-Item $tempBase -Recurse -Force -ErrorAction SilentlyContinue
        Write-Host "Progetto aggiornato." -ForegroundColor Green
    } catch {
        Write-Host "Errore durante l'applicazione: $_" -ForegroundColor Red
        Write-Host "Puoi ripristinare dal backup: $backupZip" -ForegroundColor Yellow
        exit 1
    }
} else {
    Write-Host "Nessuna modifica al progetto. Il template resta in: $template" -ForegroundColor Yellow
}

Write-Host "`nOperazione completata." -ForegroundColor Cyan
Write-Host "Backup: $backupZip" -ForegroundColor Green
