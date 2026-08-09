# Parametri del repository
$repoUrl = "https://github.com/SerialXProject/serialx-template/"
$branch = "main"

Write-Host "=== Inizializzazione Progetto SerialX ===" -ForegroundColor Cyan

# Chiedi all'utente dove creare il progetto in modo interattivo
$destinationInput = Read-Host "Inserisci il percorso completo della cartella in cui vuoi creare il progetto (es. C:\MieiProgetti\MioProgettoSerialX)"

# Verifica se l'utente ha inserito un percorso valido
if ([string]::IsNullOrWhiteSpace($destinationInput)) {
    Write-Host "Errore: Nessun percorso inserito. Operazione annullata." -ForegroundColor Red
    exit
}

$destination = $destinationInput

# Costruzione URL zip
$zipUrl = "$repoUrl/archive/refs/heads/$branch.zip"
$zipFile = "$env:TEMP\serialx_repo.zip"

Write-Host "Creazione della cartella di destinazione..." -ForegroundColor Yellow
New-Item -ItemType Directory -Force -Path $destination | Out-Null

Write-Host "Scaricamento del template in corso..." -ForegroundColor Yellow
try {
    Invoke-WebRequest -Uri $zipUrl -OutFile $zipFile
} catch {
    Write-Host "Errore durante il download del repository: $_" -ForegroundColor Red
    exit
}

Write-Host "Estrazione dei file..." -ForegroundColor Yellow
try {
    Expand-Archive -Path $zipFile -DestinationPath $destination -Force
} catch {
    Write-Host "Errore durante l'estrazione dello zip: $_" -ForegroundColor Red
    exit
}

# Pulizia del file temporaneo
if (Test-Path $zipFile) {
    Remove-Item $zipFile -Force
}

Write-Host "Template del progetto SerialX scaricato e configurato con successo in: $destination" -ForegroundColor Green