# Script PowerShell pour exécuter les tests Postman avec Newman

# Vérifier si Newman est installé
$newmanInstalled = npm list -g newman
if ($newmanInstalled -like "*newman*") {
    Write-Host "Newman est déjà installé." -ForegroundColor Green
} else {
    Write-Host "Installation de Newman..." -ForegroundColor Yellow
    npm install -g newman
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Erreur lors de l'installation de Newman. Veuillez vérifier que Node.js est installé." -ForegroundColor Red
        exit 1
    }
    Write-Host "Newman a été installé avec succès." -ForegroundColor Green
}

# Vérifier si le reporter HTML est installé
$reporterInstalled = npm list -g newman-reporter-htmlextra
if ($reporterInstalled -like "*newman-reporter-htmlextra*") {
    Write-Host "Le reporter HTML est déjà installé." -ForegroundColor Green
} else {
    Write-Host "Installation du reporter HTML..." -ForegroundColor Yellow
    npm install -g newman-reporter-htmlextra
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Erreur lors de l'installation du reporter HTML." -ForegroundColor Red
        exit 1
    }
    Write-Host "Le reporter HTML a été installé avec succès." -ForegroundColor Green
}

# Créer le répertoire pour les rapports s'il n'existe pas
$reportDir = "..\..\target\newman"
if (-not (Test-Path -Path $reportDir)) {
    New-Item -ItemType Directory -Path $reportDir -Force | Out-Null
    Write-Host "Répertoire de rapports créé: $reportDir" -ForegroundColor Green
}

# Exécuter les tests avec Newman
Write-Host "Exécution des tests Postman..." -ForegroundColor Cyan

newman run "OBP-API-Tests.postman_collection.json" `
    --environment "OBP-API-Environment.postman_environment.json" `
    --reporters cli,htmlextra,junit `
    --reporter-htmlextra-export "$reportDir\report.html" `
    --reporter-junit-export "$reportDir\report.xml"

# Vérifier le résultat
if ($LASTEXITCODE -eq 0) {
    Write-Host "Tests terminés avec succès!" -ForegroundColor Green
    Write-Host "Rapport HTML disponible à: $reportDir\report.html" -ForegroundColor Green
    Write-Host "Rapport JUnit disponible à: $reportDir\report.xml" -ForegroundColor Green
} else {
    Write-Host "Des erreurs ont été détectées lors des tests." -ForegroundColor Red
    Write-Host "Consultez les rapports pour plus de détails:" -ForegroundColor Yellow
    Write-Host "Rapport HTML: $reportDir\report.html" -ForegroundColor Yellow
    Write-Host "Rapport JUnit: $reportDir\report.xml" -ForegroundColor Yellow
    exit 1
}