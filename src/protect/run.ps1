using namespace System.Net

param($Request, $TriggerMetadata)

$password = $Request.Body.password
$file = $Request.Body.file["`$content"]
$contentType =  "application/x-zip-compressed"

$filePath = (New-Guid).Guid
$filePath
$tempPath = [IO.Path]::GetTempPath()
$tempFilePath = [IO.Path]::Combine($tempPath, $filePath)

$bytes = [Convert]::FromBase64String($file)
[IO.File]::WriteAllBytes($tempFilePath + ".zip", $bytes)


Expand-7Zip `
    -ArchiveFileName ($tempFilePath + ".zip") `
    -TargetPath $tempFilePath

Compress-7Zip `
    -Path $tempFilePath `
    -ArchiveFileName ($tempFilePath + "-secure.zip") `
    -Format Zip `
    -Password $password

$base64 = [Convert]::ToBase64String([System.IO.File]::ReadAllBytes($tempFilePath + "-secure.zip")); 

# Clean up
Remove-Item ($tempFilePath + ".zip") -Force
Remove-Item ($tempFilePath + "-secure.zip") -Force
Remove-Item $tempFilePath -Recurse -Force

# Associate values to output bindings by calling 'Push-OutputBinding'.
Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
    StatusCode = [HttpStatusCode]::OK
    Body = @{
        "`$content-type"= $contentType
        "`$content"= $base64
    }
})
