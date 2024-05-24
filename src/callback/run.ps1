using namespace System.Net

param($Request, $TriggerMetadata)

$logicappName = $Request.Body.logicappName  

# Get the callback URL for the Logic App http trigger
# Don't forget to add Logic App Contributor with resource group scope to the function app
$invokeUrl = Get-AzLogicAppTriggerCallbackUrl `
    -ResourceGroupName $env:ResourceGroupName `
    -Name $logicappName `
    -TriggerName "manual" | 
    Select-Object -ExpandProperty Value

Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
        StatusCode = [HttpStatusCode]::OK
        Body       = $invokeUrl 
    })