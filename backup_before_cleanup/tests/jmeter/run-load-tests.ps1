# Script PowerShell pour exécuter les tests de charge JMeter

# Configuration
$jmeterBinPath = "C:\apache-jmeter\bin" # Chemin vers le répertoire bin de JMeter (à modifier selon votre installation)
$testPlanPath = "OBP-API-Load-Test.jmx"
$resultDir = "..\..\target\jmeter"
$resultFile = "$resultDir\results.jtl"
$reportDir = "$resultDir\report"
$logFile = "$resultDir\jmeter.log"

# Vérifier si JMeter est installé
if (-not (Test-Path -Path $jmeterBinPath)) {
    Write-Host "JMeter n'est pas trouvé à l'emplacement spécifié: $jmeterBinPath" -ForegroundColor Red
    Write-Host "Veuillez installer JMeter et modifier le chemin dans ce script." -ForegroundColor Yellow
    exit 1
}

# Créer le répertoire pour les résultats s'il n'existe pas
if (-not (Test-Path -Path $resultDir)) {
    New-Item -ItemType Directory -Path $resultDir -Force | Out-Null
    Write-Host "Répertoire de résultats créé: $resultDir" -ForegroundColor Green
}

# Supprimer les anciens rapports s'ils existent
if (Test-Path -Path $reportDir) {
    Remove-Item -Path $reportDir -Recurse -Force
    Write-Host "Ancien répertoire de rapport supprimé." -ForegroundColor Yellow
}

# Exécuter JMeter en mode non-GUI
Write-Host "Exécution des tests de charge JMeter..." -ForegroundColor Cyan

$jmeterCmd = """$jmeterBinPath\jmeter.bat"" -n -t ""$testPlanPath"" -l ""$resultFile"" -j ""$logFile"" -e -o ""$reportDir"""

Write-Host "Commande: $jmeterCmd" -ForegroundColor Gray

Invoke-Expression $jmeterCmd

# Vérifier le résultat
if ($LASTEXITCODE -eq 0) {
    Write-Host "Tests de charge terminés avec succès!" -ForegroundColor Green
    Write-Host "Résultats JTL disponibles à: $resultFile" -ForegroundColor Green
    Write-Host "Rapport HTML disponible à: $reportDir\index.html" -ForegroundColor Green
} else {
    Write-Host "Des erreurs ont été détectées lors des tests de charge." -ForegroundColor Red
    Write-Host "Consultez le fichier journal pour plus de détails: $logFile" -ForegroundColor Yellow
    exit 1
}