# Script PowerShell principal pour configurer Jenkins pour OBP-API

$ErrorActionPreference = "Stop"

Write-Host "=================================================" -ForegroundColor Cyan
Write-Host "Configuration de Jenkins pour OBP-API" -ForegroundColor Cyan
Write-Host "=================================================" -ForegroundColor Cyan

Write-Host "Ce script va vous guider à travers les étapes de configuration de Jenkins pour OBP-API." -ForegroundColor Yellow

# Vérifier les prérequis
Write-Host "Vérification des prérequis..." -ForegroundColor Yellow
& "$PSScriptRoot\check-prerequisites.ps1"

# Demander confirmation pour continuer
$continue = Read-Host "\nVoulez-vous continuer avec la configuration ? (O/N)"
if ($continue -ne "O" -and $continue -ne "o") {
    Write-Host "Configuration annulée." -ForegroundColor Yellow
    exit 0
}

# Vérifier si Docker est en cours d'exécution
try {
    docker info | Out-Null
    Write-Host "Docker est en cours d'exécution." -ForegroundColor Green
} catch {
    Write-Host "ERREUR: Docker n'est pas en cours d'exécution. Veuillez démarrer Docker Desktop." -ForegroundColor Red
    exit 1
}

# Menu principal
function Show-Menu {
    Clear-Host
    Write-Host "=================================================" -ForegroundColor Cyan
    Write-Host "Configuration de Jenkins pour OBP-API" -ForegroundColor Cyan
    Write-Host "=================================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "1. Vérifier les prérequis" -ForegroundColor White
    Write-Host "2. Nettoyer le dépôt Git et préparer le projet" -ForegroundColor White
    Write-Host "3. Démarrer Jenkins" -ForegroundColor White
    Write-Host "4. Configurer les credentials Jenkins" -ForegroundColor White
    Write-Host "5. Configurer le job Jenkins pour OBP-API" -ForegroundColor White
    Write-Host "6. Mettre à jour le Jenkinsfile" -ForegroundColor White
    Write-Host "7. Arrêter Jenkins" -ForegroundColor White
    Write-Host "8. Quitter" -ForegroundColor White
    Write-Host ""
    Write-Host "Sélectionnez une option (1-8): " -ForegroundColor Yellow -NoNewline
}

# Boucle principale du menu
do {
    Show-Menu
    $choice = Read-Host
    
    switch ($choice) {
        "1" {
            Write-Host "\nVérification des prérequis..." -ForegroundColor Cyan
            & "$PSScriptRoot\check-prerequisites.ps1"
            Write-Host "\nAppuyez sur une touche pour continuer..." -ForegroundColor Yellow
            $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        }
        "2" {
            Write-Host "\nNettoyage du dépôt Git et préparation du projet..." -ForegroundColor Cyan
            & "$PSScriptRoot\prepare-git.ps1"
            Write-Host "\nAppuyez sur une touche pour continuer..." -ForegroundColor Yellow
            $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        }
        "3" {
            Write-Host "\nDémarrage de Jenkins..." -ForegroundColor Cyan
            & "$PSScriptRoot\start-jenkins.ps1"
            Write-Host "\nAppuyez sur une touche pour continuer..." -ForegroundColor Yellow
            $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        }
        "4" {
            Write-Host "\nConfiguration des credentials Jenkins..." -ForegroundColor Cyan
            Write-Host "REMARQUE: Cette étape nécessite que Jenkins soit en cours d'exécution." -ForegroundColor Yellow
            Write-Host "Vous devrez également générer un token d'API dans Jenkins." -ForegroundColor Yellow
            $proceed = Read-Host "Voulez-vous continuer ? (O/N)"
            
            if ($proceed -eq "O" -or $proceed -eq "o") {
                & "$PSScriptRoot\setup-credentials.ps1"
            }
            
            Write-Host "\nAppuyez sur une touche pour continuer..." -ForegroundColor Yellow
            $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        }
        "5" {
            Write-Host "\nConfiguration du job Jenkins pour OBP-API..." -ForegroundColor Cyan
            Write-Host "REMARQUE: Cette étape nécessite que Jenkins soit en cours d'exécution." -ForegroundColor Yellow
            $proceed = Read-Host "Voulez-vous continuer ? (O/N)"
            
            if ($proceed -eq "O" -or $proceed -eq "o") {
                & "$PSScriptRoot\setup-job.ps1"
            }
            
            Write-Host "\nAppuyez sur une touche pour continuer..." -ForegroundColor Yellow
            $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        }
        "6" {
            Write-Host "\nMise à jour du Jenkinsfile..." -ForegroundColor Cyan
            $proceed = Read-Host "Voulez-vous personnaliser le Jenkinsfile avec vos informations ? (O/N)"
            
            if ($proceed -eq "O" -or $proceed -eq "o") {
                & "$PSScriptRoot\update-jenkinsfile.ps1"
            }
            
            Write-Host "\nAppuyez sur une touche pour continuer..." -ForegroundColor Yellow
            $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        }
        "7" {
            Write-Host "\nArrêt de Jenkins..." -ForegroundColor Cyan
            & "$PSScriptRoot\stop-jenkins.ps1"
            Write-Host "\nAppuyez sur une touche pour continuer..." -ForegroundColor Yellow
            $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        }
        "8" {
            Write-Host "\nFin du script de configuration." -ForegroundColor Cyan
            exit 0
        }
        default {
            Write-Host "\nOption invalide. Veuillez sélectionner une option entre 1 et 8." -ForegroundColor Red
            Write-Host "Appuyez sur une touche pour continuer..." -ForegroundColor Yellow
            $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        }
    }
} while ($true)