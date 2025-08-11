# Script PowerShell pour nettoyer l'ancien travail Git et préparer le dépôt

$ErrorActionPreference = "Stop"

# Se positionner dans le répertoire racine du projet
Set-Location -Path "C:\Users\saafi\OBP-API"

# Afficher l'état actuel du dépôt Git
Write-Host "État actuel du dépôt Git :" -ForegroundColor Cyan
git status

# Demander confirmation avant de continuer
$confirmation = Read-Host "Voulez-vous nettoyer les modifications non commitées ? (O/N)"
if ($confirmation -ne "O" -and $confirmation -ne "o") {
    Write-Host "Opération annulée." -ForegroundColor Yellow
    exit 0
}

# Sauvegarder les fichiers importants créés
Write-Host "Sauvegarde des fichiers importants..." -ForegroundColor Yellow

# Créer un répertoire de sauvegarde s'il n'existe pas
if (-not (Test-Path -Path "C:\Users\saafi\OBP-API-Backup")) {
    New-Item -Path "C:\Users\saafi\OBP-API-Backup" -ItemType Directory | Out-Null
}

# Sauvegarder les répertoires kubernetes et monitoring
if (Test-Path -Path "C:\Users\saafi\OBP-API\kubernetes") {
    Copy-Item -Path "C:\Users\saafi\OBP-API\kubernetes" -Destination "C:\Users\saafi\OBP-API-Backup\kubernetes" -Recurse -Force
    Write-Host "Répertoire kubernetes sauvegardé." -ForegroundColor Green
}

if (Test-Path -Path "C:\Users\saafi\OBP-API\monitoring") {
    Copy-Item -Path "C:\Users\saafi\OBP-API\monitoring" -Destination "C:\Users\saafi\OBP-API-Backup\monitoring" -Recurse -Force
    Write-Host "Répertoire monitoring sauvegardé." -ForegroundColor Green
}

if (Test-Path -Path "C:\Users\saafi\OBP-API\jenkins") {
    Copy-Item -Path "C:\Users\saafi\OBP-API\jenkins" -Destination "C:\Users\saafi\OBP-API-Backup\jenkins" -Recurse -Force
    Write-Host "Répertoire jenkins sauvegardé." -ForegroundColor Green
}

# Sauvegarder les fichiers README-CICD.md et sonar-project.properties
if (Test-Path -Path "C:\Users\saafi\OBP-API\README-CICD.md") {
    Copy-Item -Path "C:\Users\saafi\OBP-API\README-CICD.md" -Destination "C:\Users\saafi\OBP-API-Backup\README-CICD.md" -Force
    Write-Host "Fichier README-CICD.md sauvegardé." -ForegroundColor Green
}

if (Test-Path -Path "C:\Users\saafi\OBP-API\sonar-project.properties") {
    Copy-Item -Path "C:\Users\saafi\OBP-API\sonar-project.properties" -Destination "C:\Users\saafi\OBP-API-Backup\sonar-project.properties" -Force
    Write-Host "Fichier sonar-project.properties sauvegardé." -ForegroundColor Green
}

# Nettoyer le dépôt Git
Write-Host "Nettoyage du dépôt Git..." -ForegroundColor Yellow

# Annuler toutes les modifications non commitées
git reset --hard

# Supprimer les fichiers non suivis
git clean -fd

# Vérifier si nous sommes sur la branche principale
$currentBranch = git rev-parse --abbrev-ref HEAD
if ($currentBranch -ne "main" -and $currentBranch -ne "master") {
    $switchBranch = Read-Host "Vous êtes actuellement sur la branche '$currentBranch'. Voulez-vous passer à la branche principale ? (O/N)"
    if ($switchBranch -eq "O" -or $switchBranch -eq "o") {
        # Vérifier si la branche main existe
        $mainExists = git branch --list main
        if ($mainExists) {
            git checkout main
        } else {
            # Vérifier si la branche master existe
            $masterExists = git branch --list master
            if ($masterExists) {
                git checkout master
            } else {
                Write-Host "Ni la branche 'main' ni 'master' n'existent. Création de la branche 'main'..." -ForegroundColor Yellow
                git checkout -b main
            }
        }
    }
}

# Mettre à jour le dépôt
Write-Host "Mise à jour du dépôt..." -ForegroundColor Yellow
git pull

# Restaurer les fichiers sauvegardés
$restore = Read-Host "Voulez-vous restaurer les fichiers sauvegardés ? (O/N)"
if ($restore -eq "O" -or $restore -eq "o") {
    Write-Host "Restauration des fichiers sauvegardés..." -ForegroundColor Yellow
    
    # Restaurer les répertoires
    if (Test-Path -Path "C:\Users\saafi\OBP-API-Backup\kubernetes") {
        Copy-Item -Path "C:\Users\saafi\OBP-API-Backup\kubernetes" -Destination "C:\Users\saafi\OBP-API\" -Recurse -Force
        Write-Host "Répertoire kubernetes restauré." -ForegroundColor Green
    }
    
    if (Test-Path -Path "C:\Users\saafi\OBP-API-Backup\monitoring") {
        Copy-Item -Path "C:\Users\saafi\OBP-API-Backup\monitoring" -Destination "C:\Users\saafi\OBP-API\" -Recurse -Force
        Write-Host "Répertoire monitoring restauré." -ForegroundColor Green
    }
    
    if (Test-Path -Path "C:\Users\saafi\OBP-API-Backup\jenkins") {
        Copy-Item -Path "C:\Users\saafi\OBP-API-Backup\jenkins" -Destination "C:\Users\saafi\OBP-API\" -Recurse -Force
        Write-Host "Répertoire jenkins restauré." -ForegroundColor Green
    }
    
    # Restaurer les fichiers
    if (Test-Path -Path "C:\Users\saafi\OBP-API-Backup\README-CICD.md") {
        Copy-Item -Path "C:\Users\saafi\OBP-API-Backup\README-CICD.md" -Destination "C:\Users\saafi\OBP-API\" -Force
        Write-Host "Fichier README-CICD.md restauré." -ForegroundColor Green
    }
    
    if (Test-Path -Path "C:\Users\saafi\OBP-API-Backup\sonar-project.properties") {
        Copy-Item -Path "C:\Users\saafi\OBP-API-Backup\sonar-project.properties" -Destination "C:\Users\saafi\OBP-API\" -Force
        Write-Host "Fichier sonar-project.properties restauré." -ForegroundColor Green
    }
}

Write-Host "Préparation Git terminée." -ForegroundColor Green
Write-Host "Vous pouvez maintenant démarrer Jenkins avec le script start-jenkins.ps1" -ForegroundColor Cyan