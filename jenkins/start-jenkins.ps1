# Script PowerShell pour démarrer Jenkins

$ErrorActionPreference = "Stop"

# Vérifier si Docker est en cours d'exécution
try {
    docker info | Out-Null
    Write-Host "Docker est en cours d'exécution." -ForegroundColor Green
} catch {
    Write-Host "ERREUR: Docker n'est pas en cours d'exécution. Veuillez démarrer Docker Desktop." -ForegroundColor Red
    exit 1
}

# Vérifier si le conteneur Jenkins existe déjà
$jenkinsRunning = docker ps -a | Select-String "jenkins-jenkins"
if ($jenkinsRunning) {
    Write-Host "Un conteneur Jenkins existe déjà." -ForegroundColor Yellow
    
    # Vérifier s'il est en cours d'exécution
    $isRunning = docker ps | Select-String "jenkins-jenkins"
    if ($isRunning) {
        Write-Host "Jenkins est déjà en cours d'exécution. Accessible à l'adresse http://localhost:18080" -ForegroundColor Green
    } else {
        Write-Host "Démarrage du conteneur Jenkins existant..." -ForegroundColor Yellow
        docker start jenkins-jenkins
        Write-Host "Jenkins démarré. Accessible à l'adresse http://localhost:18080" -ForegroundColor Green
    }
} else {
    # Construire et démarrer Jenkins avec Docker Compose
    Write-Host "Construction et démarrage de Jenkins..." -ForegroundColor Yellow
    
    # Se positionner dans le répertoire jenkins
    Set-Location -Path $PSScriptRoot
    
    # Démarrer avec Docker Compose
    docker-compose up -d
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "Jenkins démarré avec succès. Accessible à l'adresse http://localhost:18080" -ForegroundColor Green
        Write-Host "Initialisation en cours, veuillez patienter quelques instants..." -ForegroundColor Yellow
    } else {
        Write-Host "ERREUR: Échec du démarrage de Jenkins." -ForegroundColor Red
        exit 1
    }
}

# Attendre que Jenkins soit prêt
Write-Host "Vérification de l'état de Jenkins..." -ForegroundColor Yellow
$maxAttempts = 30
$attempts = 0
$ready = $false

while (-not $ready -and $attempts -lt $maxAttempts) {
    $attempts++
    try {
        $response = Invoke-WebRequest -Uri "http://localhost:18080/login" -UseBasicParsing -ErrorAction SilentlyContinue
        if ($response.StatusCode -eq 200) {
            $ready = $true
            Write-Host "Jenkins est prêt !" -ForegroundColor Green
            Write-Host "Accédez à Jenkins via: http://localhost:18080" -ForegroundColor Cyan
        }
    } catch {
        Write-Host "En attente que Jenkins soit prêt... ($attempts/$maxAttempts)" -ForegroundColor Yellow
        Start-Sleep -Seconds 5
    }
}

if (-not $ready) {
    Write-Host "AVERTISSEMENT: Jenkins n'a pas répondu dans le délai imparti, mais il pourrait encore être en cours de démarrage." -ForegroundColor Yellow
    Write-Host "Vérifiez manuellement l'état à l'adresse http://localhost:18080" -ForegroundColor Yellow
}