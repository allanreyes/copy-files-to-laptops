# Gets the callback URLs all Logic Apps that match the naming convention logic-$pcccode* in the resource group
# Don't forget to add Logic App Contributor with resource group scope to the function app

using namespace System.Net

param($Request, $TriggerMetadata)

$pcccode = $Request.Body.pcccode # e.g. MA01

# Get list of all Logic Apps in the resource group
$logicApps = Get-AzLogicApp -ResourceGroupName $env:ResourceGroupName

$urls = @()
foreach ($logicApp in $logicApps) {

    # If the logic app name does not start with logic-$pcccode, skip
    if($logicApp.Name.StartsWith("logic-$pcccode") -eq $false) {
        continue
    }

    # If the logic app is not enabled, skip
    if($logicApp.State -ne "Enabled") {
        continue
    }

    # Get the callback URL for the Logic App http trigger
    $invokeUrl = Get-AzLogicAppTriggerCallbackUrl `
        -ResourceGroupName $env:ResourceGroupName `
        -Name $logicApp.Name `
        -TriggerName "manual" | 
        Select-Object -ExpandProperty Value

    $urls +=  $invokeUrl
}
Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
        StatusCode = [HttpStatusCode]::OK
        Body       = $urls 
    })