# Script PowerShell pour arrêter Jenkins

$ErrorActionPreference = "Stop"

# Vérifier si Docker est en cours d'exécution
try {
    docker info | Out-Null
    Write-Host "Docker est en cours d'exécution." -ForegroundColor Green
} catch {
    Write-Host "ERREUR: Docker n'est pas en cours d'exécution. Impossible d'arrêter Jenkins." -ForegroundColor Red
    exit 1
}

# Vérifier si le conteneur Jenkins est en cours d'exécution
$jenkinsRunning = docker ps | Select-String "jenkins-jenkins"
if ($jenkinsRunning) {
    Write-Host "Arrêt de Jenkins..." -ForegroundColor Yellow
    
    # Se positionner dans le répertoire jenkins
    Set-Location -Path $PSScriptRoot
    
    # Arrêter avec Docker Compose
    docker-compose down
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "Jenkins arrêté avec succès." -ForegroundColor Green
    } else {
        Write-Host "ERREUR: Échec de l'arrêt de Jenkins." -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "Jenkins n'est pas en cours d'exécution." -ForegroundColor Yellow
}