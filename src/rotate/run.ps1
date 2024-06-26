using namespace System.Net

param($Request, $TriggerMetadata)

$sitecode = $Request.Body.sitecode
# [char]111 = o
# [char]79 = O
# Generate a 9 character password using only letters and numbers
$password = ([char[]] ([char]97..[char]110) + ([char]112..[char]122) + ([char]65..[char]78) +([char]80..[char]90) + 1..9 | 
    Sort-Object { Get-Random })[0..9] -join '' | 
    ForEach-Object { $_.ToUpper() }

$securePassword = ConvertTo-SecureString -String $password -AsPlainText -Force

#Connect to Azure Keyvault and create a new version of the secret
# Don't forget to add Key Vault Secrets Officer with keyvault scope to the function app
Set-AzKeyVaultSecret -VaultName $env:KeyVaultName -Name $sitecode -SecretValue $securePassword

Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
        StatusCode = [HttpStatusCode]::OK
        Body       = $password
    })
