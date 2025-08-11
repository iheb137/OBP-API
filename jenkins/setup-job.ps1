# Script PowerShell pour configurer le job Jenkins pour OBP-API

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

Write-Host "Ce script va configurer le job Jenkins pour OBP-API." -ForegroundColor Cyan

# Demander l'URL du dépôt Git
$gitRepoUrl = Read-Host "Veuillez entrer l'URL du dépôt Git OBP-API (par défaut: https://github.com/votre-organisation/OBP-API.git)"

if ([string]::IsNullOrEmpty($gitRepoUrl)) {
    $gitRepoUrl = "https://github.com/votre-organisation/OBP-API.git"
}

# Demander la branche Git
$gitBranch = Read-Host "Veuillez entrer la branche Git à utiliser (par défaut: main)"

if ([string]::IsNullOrEmpty($gitBranch)) {
    $gitBranch = "main"
}

# Créer le fichier XML de configuration du job
$jobConfigXml = @"
<?xml version='1.1' encoding='UTF-8'?>
<flow-definition plugin="workflow-job@2.40">
  <actions>
    <org.jenkinsci.plugins.pipeline.modeldefinition.actions.DeclarativeJobAction plugin="pipeline-model-definition@1.8.4"/>
    <org.jenkinsci.plugins.pipeline.modeldefinition.actions.DeclarativeJobPropertyTrackerAction plugin="pipeline-model-definition@1.8.4">
      <jobProperties/>
      <triggers/>
      <parameters/>
      <options/>
    </org.jenkinsci.plugins.pipeline.modeldefinition.actions.DeclarativeJobPropertyTrackerAction>
  </actions>
  <description>Pipeline CI/CD pour OBP-API</description>
  <keepDependencies>false</keepDependencies>
  <properties>
    <jenkins.model.BuildDiscarderProperty>
      <strategy class="hudson.tasks.LogRotator">
        <daysToKeep>30</daysToKeep>
        <numToKeep>10</numToKeep>
        <artifactDaysToKeep>-1</artifactDaysToKeep>
        <artifactNumToKeep>-1</artifactNumToKeep>
      </strategy>
    </jenkins.model.BuildDiscarderProperty>
    <org.jenkinsci.plugins.workflow.job.properties.PipelineTriggersJobProperty>
      <triggers>
        <hudson.triggers.SCMTrigger>
          <spec>H/15 * * * *</spec>
          <ignorePostCommitHooks>false</ignorePostCommitHooks>
        </hudson.triggers.SCMTrigger>
      </triggers>
    </org.jenkinsci.plugins.workflow.job.properties.PipelineTriggersJobProperty>
    <hudson.model.ParametersDefinitionProperty>
      <parameterDefinitions>
        <hudson.model.StringParameterDefinition>
          <name>ENVIRONMENT</name>
          <description>Environnement de déploiement (dev, test, prod)</description>
          <defaultValue>dev</defaultValue>
          <trim>true</trim>
        </hudson.model.StringParameterDefinition>
        <hudson.model.BooleanParameterDefinition>
          <name>RUN_TESTS</name>
          <description>Exécuter les tests</description>
          <defaultValue>true</defaultValue>
        </hudson.model.BooleanParameterDefinition>
        <hudson.model.BooleanParameterDefinition>
          <name>DEPLOY_TO_K8S</name>
          <description>Déployer sur Kubernetes</description>
          <defaultValue>false</defaultValue>
        </hudson.model.BooleanParameterDefinition>
      </parameterDefinitions>
    </hudson.model.ParametersDefinitionProperty>
  </properties>
  <definition class="org.jenkinsci.plugins.workflow.cps.CpsScmFlowDefinition" plugin="workflow-cps@2.90">
    <scm class="hudson.plugins.git.GitSCM" plugin="git@4.7.1">
      <configVersion>2</configVersion>
      <userRemoteConfigs>
        <hudson.plugins.git.UserRemoteConfig>
          <url>$gitRepoUrl</url>
        </hudson.plugins.git.UserRemoteConfig>
      </userRemoteConfigs>
      <branches>
        <hudson.plugins.git.BranchSpec>
          <name>*/$gitBranch</name>
        </hudson.plugins.git.BranchSpec>
      </branches>
      <doGenerateSubmoduleConfigurations>false</doGenerateSubmoduleConfigurations>
      <submoduleCfg class="empty-list"/>
      <extensions/>
    </scm>
    <scriptPath>Jenkinsfile</scriptPath>
    <lightweight>true</lightweight>
  </definition>
  <triggers/>
  <disabled>false</disabled>
</flow-definition>
"@

# Créer un fichier temporaire pour la configuration du job
$tempFile = [System.IO.Path]::GetTempFileName()
Set-Content -Path $tempFile -Value $jobConfigXml

# Créer le job Jenkins via l'API
Write-Host "Création du job Jenkins 'OBP-API-Pipeline'..." -ForegroundColor Yellow

try {
    $response = Invoke-RestMethod -Uri "http://localhost:18080/createItem?name=OBP-API-Pipeline" -Method Post -ContentType "application/xml" -InFile $tempFile
    Write-Host "Job Jenkins 'OBP-API-Pipeline' créé avec succès." -ForegroundColor Green
} catch {
    Write-Host "ERREUR: Échec de la création du job Jenkins." -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    
    # Vérifier si le job existe déjà
    try {
        $jobExists = Invoke-RestMethod -Uri "http://localhost:18080/job/OBP-API-Pipeline/api/json" -Method Get -ErrorAction SilentlyContinue
        Write-Host "Le job 'OBP-API-Pipeline' existe déjà. Mise à jour de la configuration..." -ForegroundColor Yellow
        
        try {
            $updateResponse = Invoke-RestMethod -Uri "http://localhost:18080/job/OBP-API-Pipeline/config.xml" -Method Post -ContentType "application/xml" -InFile $tempFile
            Write-Host "Configuration du job 'OBP-API-Pipeline' mise à jour avec succès." -ForegroundColor Green
        } catch {
            Write-Host "ERREUR: Échec de la mise à jour de la configuration du job." -ForegroundColor Red
            Write-Host $_.Exception.Message -ForegroundColor Red
        }
    } catch {
        # Le job n'existe pas, une autre erreur s'est produite
        Write-Host "ERREUR: Impossible de vérifier si le job existe déjà." -ForegroundColor Red
    }
}

# Supprimer le fichier temporaire
Remove-Item -Path $tempFile -Force

Write-Host "\nConfiguration du job terminée." -ForegroundColor Green
Write-Host "Vous pouvez accéder au job via: http://localhost:18080/job/OBP-API-Pipeline/" -ForegroundColor Cyan