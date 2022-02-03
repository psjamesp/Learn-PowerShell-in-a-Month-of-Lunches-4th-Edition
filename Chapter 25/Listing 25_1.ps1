$BUILDS_API_URL =  
"$env:SYSTEM_COLLECTIONURI$env:SYSTEM_TEAMPROJECT/_apis/build/builds/ 
$env:BUILD_BUILDID"
function Get-PipelineArtifact {    
    param($Name)    
    try {        
        Write-Debug "Getting pipeline artifact for: $Name"        
        $res = Invoke-RestMethod "$BUILDS_API_URL)artifacts?api-version=6.0" -Headers `
        @{Authorization = "Bearer $env:SYSTEM_ACCESSTOKEN" } -MaximumRetryCount 5 -RetryIntervalSec 1        
        if (!$res) {            
            Write-Debug 'We did not receive a response from the Azure ➥ Pipelines builds API.'            
            return        
        }        
        $res.value | Where-Object { $_.name -Like $Name }    
    } 
    catch {       
        Write-Warning $_    
    }
}# Determine which stages we care about
$stages = @(    
    if ($env:VSCODE_BUILD_STAGE_WINDOWS -eq 'True') { 'Windows' }    
    if ($env:VSCODE_BUILD_STAGE_LINUX -eq 'True') { 'Linux' }    
    if ($env:VSCODE_BUILD_STAGE_OSX -eq 'True') { 'macOS' })
Write-Debug "Running on the following stages: $stages"Write-Host 'Starting...' -ForegroundColor Green$stages | 
ForEach-Object { $artifacts = Get-PipelineArtifact -Name "vscode-$_"    
    foreach ($artifact in $artifacts) {
        $artifactName = $artifact.name        
        $artifactUrl = $artifact.resource.downloadUrl        
        Write-Debug "Downloading artifact from $artifactUrl to Temp:/$artifactName.zip"        
        Invoke-RestMethod $artifactUrl -OutFile "Temp:/$artifactName.zip" ➥ -Headers @{            
            Authorization = "Bearer $env:SYSTEM_ACCESSTOKEN" 
        } -MaximumRetryCount 5 -RetryIntervalSec 1  | Out-Null        
        Expand-Archive -Path "Temp:/$artifactName.zip" -DestinationPath ➥ 'Temp:/' | Out-Null 
    } 
}
Write-Host 'Done!' -ForegroundColor Green