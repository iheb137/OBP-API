# Script PowerShell pour mettre à jour le Jenkinsfile avec les informations personnalisées

$ErrorActionPreference = "Stop"

# Vérifier si le Jenkinsfile existe
if (-not (Test-Path -Path "C:\Users\saafi\OBP-API\Jenkinsfile")) {
    Write-Host "ERREUR: Jenkinsfile non trouvé à l'emplacement C:\Users\saafi\OBP-API\Jenkinsfile" -ForegroundColor Red
    exit 1
}

# Lire le contenu actuel du Jenkinsfile
$jenkinsfileContent = Get-Content -Path "C:\Users\saafi\OBP-API\Jenkinsfile" -Raw

Write-Host "=================================================" -ForegroundColor Cyan
Write-Host "Mise à jour du Jenkinsfile" -ForegroundColor Cyan
Write-Host "=================================================" -ForegroundColor Cyan

# Demander les informations personnalisées
Write-Host "\nVeuillez fournir les informations suivantes pour personnaliser le Jenkinsfile :" -ForegroundColor Yellow

# Nom du projet et de l'image Docker
$projectName = Read-Host "Nom du projet (par défaut: obp-api)"
if ([string]::IsNullOrEmpty($projectName)) {
    $projectName = "obp-api"
}

$dockerImage = Read-Host "Nom de l'image Docker (par défaut: biat-it/obp-api)"
if ([string]::IsNullOrEmpty($dockerImage)) {
    $dockerImage = "biat-it/obp-api"
}

# Informations Jira
$jiraUrl = Read-Host "URL Jira (par défaut: https://biat-it.atlassian.net)"
if ([string]::IsNullOrEmpty($jiraUrl)) {
    $jiraUrl = "https://biat-it.atlassian.net"
}

$jiraProject = Read-Host "Code du projet Jira (par défaut: OBP)"
if ([string]::IsNullOrEmpty($jiraProject)) {
    $jiraProject = "OBP"
}

# Informations Docker Hub
$dockerHubUsername = Read-Host "Nom d'utilisateur Docker Hub (par défaut: biatituser)"
if ([string]::IsNullOrEmpty($dockerHubUsername)) {
    $dockerHubUsername = "biatituser"
}

$dockerHubPassword = Read-Host "Mot de passe Docker Hub (par défaut: biatitpassword)" -AsSecureString
$dockerHubPasswordPlain = if ($dockerHubPassword.Length -eq 0) { "biatitpassword" } else { [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($dockerHubPassword)) }

# Email pour les notifications
$notificationEmail = Read-Host "Email pour les notifications (par défaut: equipe-devops@biat-it.com)"
if ([string]::IsNullOrEmpty($notificationEmail)) {
    $notificationEmail = "equipe-devops@biat-it.com"
}

# Mettre à jour le contenu du Jenkinsfile
Write-Host "\nMise à jour du Jenkinsfile..." -ForegroundColor Yellow

# Remplacer les valeurs dans le Jenkinsfile
$jenkinsfileContent = $jenkinsfileContent -replace "PROJECT_NAME = 'obp-api'", "PROJECT_NAME = '$projectName'"
$jenkinsfileContent = $jenkinsfileContent -replace "DOCKER_IMAGE = 'biat-it/obp-api'", "DOCKER_IMAGE = '$dockerImage'"
$jenkinsfileContent = $jenkinsfileContent -replace "JIRA_URL = 'https://biat-it.atlassian.net'", "JIRA_URL = '$jiraUrl'"
$jenkinsfileContent = $jenkinsfileContent -replace "JIRA_PROJECT = 'OBP'", "JIRA_PROJECT = '$jiraProject'"
$jenkinsfileContent = $jenkinsfileContent -replace "docker login -u biatituser -p biatitpassword", "docker login -u $dockerHubUsername -p $dockerHubPasswordPlain"
$jenkinsfileContent = $jenkinsfileContent -replace "to: 'equipe-devops@biat-it.com'", "to: '$notificationEmail'"

# Mettre à jour les références à l'image Docker dans les commandes kubectl
$jenkinsfileContent = $jenkinsfileContent -replace "image: biat-it/obp-api:", "image: $dockerImage:"

# Sauvegarder le Jenkinsfile original
$backupPath = "C:\Users\saafi\OBP-API\Jenkinsfile.bak"
Copy-Item -Path "C:\Users\saafi\OBP-API\Jenkinsfile" -Destination $backupPath -Force
Write-Host "Sauvegarde du Jenkinsfile original créée à $backupPath" -ForegroundColor Green

# Écrire le nouveau contenu dans le Jenkinsfile
Set-Content -Path "C:\Users\saafi\OBP-API\Jenkinsfile" -Value $jenkinsfileContent

Write-Host "\nJenkinsfile mis à jour avec succès." -ForegroundColor Green
Write-Host "Vous pouvez maintenant utiliser le Jenkinsfile personnalisé pour votre pipeline CI/CD." -ForegroundColor Cyan