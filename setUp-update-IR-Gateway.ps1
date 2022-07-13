param(
    [Alias("key")]
    [Parameter(Mandatory=$true)]
    [string]
    $authKey,
    [Alias("port")]
    [Parameter(Mandatory=$false)]
    [string]
    $remoteAccessPort,
    [Alias("cert")]
    [Parameter(Mandatory=$false)]
    [string]
    $remoteAccessCertThumbprint
)
$ErrorActionPreference = "Stop"




function Get-PushedIntegrationRuntimeVersion([string] $key, [string] $port, [string] $cert) {
    $url = "https://go.microsoft.com/fwlink/?linkid=839822"
    $request = Invoke-WebRequest -Method Head -Uri $url
    $uri = $request.BaseResponse.ResponseUri.AbsoluteUri 
    #download the latest integration runtime
    $folder = "C:\Users\oasis-admin"
    $output = Join-Path $folder "IntegrationRuntime.msi"
    Write-Host "Start to download Microsoft Integration Runtime installer of version $version from $uri"
    Invoke-WebRequest -Uri $uri -OutFile $output
    Write-Host "Microsoft Integration Runtime installer has been downloaded to $output."
    #install the ir
    $installArgs = "/i $output /quiet"
    $process = Start-Process "msiexec.exe" $installArgs -Wait -PassThru -NoNewWindow
    if ($process.ExitCode -ne 0) {
        throw "Failed to installMicrosoft Integration Runtime."
    }
    Write-Host "Succeed to install Microsoft Integration Runtime."
    
    #register to Microsoft Integration Runtime
    $filePath = Get-ItemPropertyValue "hklm:\Software\Microsoft\DataTransfer\DataManagementGateway\ConfigurationManager" "DiacmdPath"
    if ([string]::IsNullOrEmpty($filePath))
    {
        throw "Get-InstalledFilePath: Cannot find installed File Path"
    }
    
    $cmd = (Split-Path -Parent $filePath) + "\dmgcmd.exe"
    
    # if (![string]::IsNullOrEmpty($port))
    # {
    #     Write-Host "Start to enable remote access."
    #     $process = Start-Process $cmd "-era $port $cert" -Wait -PassThru -NoNewWindow
    #     if ($process.ExitCode -ne 0)
    #     {
    #         throw "Failed to enable remote access. Exit code: $($process.ExitCode)"
    #     }
    #     Write-Host "Succeed to enable remote access."
    # }
    $process = Start-Process $cmd "-k $key" -Wait -PassThru -NoNewWindow
    if ($process.ExitCode -ne 0)
    {
        throw "Failed to register Microsoft Integration Runtime. Exit code: $($process.ExitCode)"
    }
    Write-Host "Succeed to register Microsoft Integration Runtime."


    return $version
}

Get-PushedIntegrationRuntimeVersion $authKey 

# Get-AzDataFactoryV2IntegrationRuntimeKey -ResourceGroupName $resourceGroupName -DataFactoryName $dataFactoryName -Name $selfHostedIntegrationRuntimeName  
# $key = "IR@f73ed03e-daa7-499d-adee-731ffa4b5bb1@adf-oasis-rec@ServiceEndpoint=adf-oasis-rec.northeurope.datafactory.azure.net@k3+kSTi9UPwwPafqYwhTUcIsBTtotVOmi0UNdxcxQ88=""