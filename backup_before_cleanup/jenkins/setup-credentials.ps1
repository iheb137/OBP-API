# Script PowerShell pour configurer les credentials Jenkins

$ErrorActionPreference = "Stop"

# Vérifier si Docker est en cours d'exécution
try {
    docker info | Out-Null
    Write-Host "Docker est en cours d'exécution." -ForegroundColor Green
} catch {
    Write-Host "ERREUR: Docker n'est pas en cours d'exécution. Veuillez démarrer Docker Desktop." -ForegroundColor Red
    exit 1
}

# Vérifier si le conteneur Jenkins est en cours d'exécution
$jenkinsRunning = docker ps | Select-String "jenkins-jenkins"
if (-not $jenkinsRunning) {
    Write-Host "ERREUR: Jenkins n'est pas en cours d'exécution. Veuillez démarrer Jenkins d'abord." -ForegroundColor Red
    exit 1
}

Write-Host "Ce script va vous aider à configurer les credentials Jenkins nécessaires." -ForegroundColor Cyan
Write-Host "Les credentials seront configurés via l'API Jenkins." -ForegroundColor Cyan
Write-Host "Vous aurez besoin du token d'API Jenkins pour continuer." -ForegroundColor Cyan

# Demander le token d'API Jenkins
$jenkinsToken = Read-Host "Veuillez entrer votre token d'API Jenkins (vous pouvez le générer dans Jenkins > votre compte > Configure > API Token)"

if ([string]::IsNullOrEmpty($jenkinsToken)) {
    Write-Host "ERREUR: Token d'API Jenkins non fourni." -ForegroundColor Red
    exit 1
}

# Fonction pour créer un credential
function Create-JenkinsCredential {
    param (
        [string]$id,
        [string]$description,
        [string]$username,
        [string]$password,
        [string]$type = "UsernamePasswordCredentialsImpl"
    )
    
    $xml = @"
<com.cloudbees.plugins.credentials.impl.$type>
  <scope>GLOBAL</scope>
  <id>$id</id>
  <description>$description</description>
  <username>$username</username>
  <password>$password</password>
</com.cloudbees.plugins.credentials.impl.$type>
"@
    
    $encodedXml = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($xml))
    
    $url = "http://localhost:18080/credentials/store/system/domain/_/createCredentials"
    $headers = @{
        "Authorization" = "Basic $encodedXml"
        "Content-Type" = "application/xml"
    }
    
    try {
        Invoke-RestMethod -Uri $url -Method Post -Headers $headers -Body $xml
        Write-Host "Credential '$id' créé avec succès." -ForegroundColor Green
    } catch {
        Write-Host "ERREUR: Échec de la création du credential '$id'." -ForegroundColor Red
        Write-Host $_.Exception.Message -ForegroundColor Red
    }
}

# Configurer les credentials Docker Hub
Write-Host "\nConfiguration des credentials Docker Hub" -ForegroundColor Cyan
$dockerHubUsername = Read-Host "Nom d'utilisateur Docker Hub"
$dockerHubPassword = Read-Host "Mot de passe Docker Hub" -AsSecureString
$dockerHubPasswordPlain = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($dockerHubPassword))

Create-JenkinsCredential -id "docker-hub-credentials" -description "Docker Hub Credentials" -username $dockerHubUsername -password $dockerHubPasswordPlain

# Configurer les credentials SonarQube
Write-Host "\nConfiguration du token SonarQube" -ForegroundColor Cyan
$sonarQubeToken = Read-Host "Token SonarQube"

Create-JenkinsCredential -id "sonarqube-token" -description "SonarQube Token" -username "token" -password $sonarQubeToken

# Configurer les credentials Jira
Write-Host "\nConfiguration des credentials Jira" -ForegroundColor Cyan
$jiraUsername = Read-Host "Nom d'utilisateur Jira"
$jiraPassword = Read-Host "Mot de passe/Token Jira" -AsSecureString
$jiraPasswordPlain = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($jiraPassword))

Create-JenkinsCredential -id "jira-credentials" -description "Jira Credentials" -username $jiraUsername -password $jiraPasswordPlain

# Configurer les credentials Kubernetes
Write-Host "\nConfiguration des credentials Kubernetes" -ForegroundColor Cyan
Write-Host "Pour Kubernetes, vous devez généralement configurer un fichier kubeconfig." -ForegroundColor Yellow
Write-Host "Vous pouvez le faire manuellement dans l'interface Jenkins." -ForegroundColor Yellow

Write-Host "\nConfiguration des credentials terminée." -ForegroundColor Green
Write-Host "Veuillez vérifier dans l'interface Jenkins que les credentials ont été correctement créés." -ForegroundColor Cyan
Write-Host "URL: http://localhost:18080/credentials/" -ForegroundColor Cyan