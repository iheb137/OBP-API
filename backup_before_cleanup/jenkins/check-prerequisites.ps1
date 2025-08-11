# Script PowerShell pour vérifier les prérequis nécessaires à la configuration de Jenkins

$ErrorActionPreference = "Stop"

Write-Host "=================================================" -ForegroundColor Cyan
Write-Host "Vérification des prérequis pour Jenkins" -ForegroundColor Cyan
Write-Host "=================================================" -ForegroundColor Cyan

# Fonction pour vérifier si une commande est disponible
function Test-CommandExists {
    param ($command)
    $oldPreference = $ErrorActionPreference
    $ErrorActionPreference = 'stop'
    try {
        if (Get-Command $command) { return $true }
    } catch {
        return $false
    } finally {
        $ErrorActionPreference = $oldPreference
    }
}

# Vérifier Docker
Write-Host "\nVérification de Docker..." -ForegroundColor Yellow
try {
    $dockerVersion = docker --version
    Write-Host "✅ Docker est installé: $dockerVersion" -ForegroundColor Green
    
    # Vérifier si Docker est en cours d'exécution
    docker info | Out-Null
    Write-Host "✅ Docker est en cours d'exécution." -ForegroundColor Green
} catch {
    Write-Host "❌ Docker n'est pas installé ou n'est pas en cours d'exécution." -ForegroundColor Red
    Write-Host "   Veuillez installer Docker Desktop et le démarrer: https://www.docker.com/products/docker-desktop" -ForegroundColor Yellow
}

# Vérifier Git
Write-Host "\nVérification de Git..." -ForegroundColor Yellow
try {
    $gitVersion = git --version
    Write-Host "✅ Git est installé: $gitVersion" -ForegroundColor Green
} catch {
    Write-Host "❌ Git n'est pas installé." -ForegroundColor Red
    Write-Host "   Veuillez installer Git: https://git-scm.com/downloads" -ForegroundColor Yellow
}

# Vérifier PowerShell
Write-Host "\nVérification de PowerShell..." -ForegroundColor Yellow
$psVersion = $PSVersionTable.PSVersion
Write-Host "✅ PowerShell est installé: $($psVersion.Major).$($psVersion.Minor).$($psVersion.Patch)" -ForegroundColor Green

# Vérifier Java (optionnel)
Write-Host "\nVérification de Java (optionnel)..." -ForegroundColor Yellow
try {
    $javaVersion = java -version 2>&1
    Write-Host "✅ Java est installé: $($javaVersion[0])" -ForegroundColor Green
} catch {
    Write-Host "⚠️ Java n'est pas installé ou n'est pas dans le PATH." -ForegroundColor Yellow
    Write-Host "   Ce n'est pas obligatoire car Java sera exécuté dans le conteneur Jenkins." -ForegroundColor Yellow
}

# Vérifier Maven (optionnel)
Write-Host "\nVérification de Maven (optionnel)..." -ForegroundColor Yellow
try {
    $mavenVersion = mvn --version 2>&1
    Write-Host "✅ Maven est installé: $($mavenVersion[0])" -ForegroundColor Green
} catch {
    Write-Host "⚠️ Maven n'est pas installé ou n'est pas dans le PATH." -ForegroundColor Yellow
    Write-Host "   Ce n'est pas obligatoire car Maven sera exécuté dans le conteneur Jenkins." -ForegroundColor Yellow
}

# Vérifier kubectl (optionnel)
Write-Host "\nVérification de kubectl (optionnel)..." -ForegroundColor Yellow
try {
    $kubectlVersion = kubectl version --client 2>&1
    Write-Host "✅ kubectl est installé" -ForegroundColor Green
} catch {
    Write-Host "⚠️ kubectl n'est pas installé ou n'est pas dans le PATH." -ForegroundColor Yellow
    Write-Host "   Ce n'est pas obligatoire car kubectl sera exécuté dans le conteneur Jenkins." -ForegroundColor Yellow
}

# Vérifier les ports utilisés
Write-Host "\nVérification des ports..." -ForegroundColor Yellow
$port18080 = netstat -ano | Select-String ":18080"
if ($port18080) {
    Write-Host "⚠️ Le port 18080 est déjà utilisé. Jenkins pourrait ne pas démarrer correctement." -ForegroundColor Yellow
    Write-Host "   Processus utilisant le port: $port18080" -ForegroundColor Yellow
} else {
    Write-Host "✅ Le port 18080 est disponible pour Jenkins." -ForegroundColor Green
}

$port50000 = netstat -ano | Select-String ":50000"
if ($port50000) {
    Write-Host "⚠️ Le port 50000 est déjà utilisé. Les agents Jenkins pourraient ne pas se connecter correctement." -ForegroundColor Yellow
    Write-Host "   Processus utilisant le port: $port50000" -ForegroundColor Yellow
} else {
    Write-Host "✅ Le port 50000 est disponible pour les agents Jenkins." -ForegroundColor Green
}

# Vérifier l'espace disque
Write-Host "\nVérification de l'espace disque..." -ForegroundColor Yellow
$drive = Get-PSDrive -Name C
$freeSpaceGB = [math]::Round($drive.Free / 1GB, 2)
$totalSpaceGB = [math]::Round(($drive.Used + $drive.Free) / 1GB, 2)
$freeSpacePercentage = [math]::Round(($drive.Free / ($drive.Used + $drive.Free)) * 100, 2)

Write-Host "Espace disque disponible sur C: $freeSpaceGB GB / $totalSpaceGB GB ($freeSpacePercentage%)" -ForegroundColor White

if ($freeSpaceGB -lt 10) {
    Write-Host "⚠️ L'espace disque disponible est faible. Il est recommandé d'avoir au moins 10 GB d'espace libre." -ForegroundColor Yellow
} else {
    Write-Host "✅ L'espace disque est suffisant." -ForegroundColor Green
}

# Résumé
Write-Host "\n=================================================" -ForegroundColor Cyan
Write-Host "Résumé des prérequis" -ForegroundColor Cyan
Write-Host "=================================================" -ForegroundColor Cyan

Write-Host "\nPrérequis obligatoires:" -ForegroundColor White
Write-Host "- Docker: $(if (Test-CommandExists 'docker') { "✅ Installé" } else { "❌ Non installé" })" -ForegroundColor $(if (Test-CommandExists 'docker') { "Green" } else { "Red" })
Write-Host "- Git: $(if (Test-CommandExists 'git') { "✅ Installé" } else { "❌ Non installé" })" -ForegroundColor $(if (Test-CommandExists 'git') { "Green" } else { "Red" })
Write-Host "- PowerShell: ✅ Installé" -ForegroundColor Green

Write-Host "\nPrérequis optionnels:" -ForegroundColor White
Write-Host "- Java: $(if (Test-CommandExists 'java') { "✅ Installé" } else { "⚠️ Non installé" })" -ForegroundColor $(if (Test-CommandExists 'java') { "Green" } else { "Yellow" })
Write-Host "- Maven: $(if (Test-CommandExists 'mvn') { "✅ Installé" } else { "⚠️ Non installé" })" -ForegroundColor $(if (Test-CommandExists 'mvn') { "Green" } else { "Yellow" })
Write-Host "- kubectl: $(if (Test-CommandExists 'kubectl') { "✅ Installé" } else { "⚠️ Non installé" })" -ForegroundColor $(if (Test-CommandExists 'kubectl') { "Green" } else { "Yellow" })

Write-Host "\nPorts:" -ForegroundColor White
Write-Host "- 18080 (Jenkins): $(if ($port18080) { "⚠️ Utilisé" } else { "✅ Disponible" })" -ForegroundColor $(if ($port18080) { "Yellow" } else { "Green" })
Write-Host "- 50000 (Agents Jenkins): $(if ($port50000) { "⚠️ Utilisé" } else { "✅ Disponible" })" -ForegroundColor $(if ($port50000) { "Yellow" } else { "Green" })

Write-Host "\nEspace disque:" -ForegroundColor White
Write-Host "- Espace libre: $freeSpaceGB GB / $totalSpaceGB GB ($freeSpacePercentage%)" -ForegroundColor $(if ($freeSpaceGB -lt 10) { "Yellow" } else { "Green" })

# Conclusion
Write-Host "\n=================================================" -ForegroundColor Cyan
if ((Test-CommandExists 'docker') -and (Test-CommandExists 'git')) {
    Write-Host "✅ Tous les prérequis obligatoires sont installés." -ForegroundColor Green
    Write-Host "   Vous pouvez continuer avec la configuration de Jenkins." -ForegroundColor Green
} else {
    Write-Host "❌ Certains prérequis obligatoires ne sont pas installés." -ForegroundColor Red
    Write-Host "   Veuillez installer les prérequis manquants avant de continuer." -ForegroundColor Red
}
Write-Host "=================================================" -ForegroundColor Cyan