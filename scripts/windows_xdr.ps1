# Define parameters

$logsPath = "C:\Packages\Plugins\run_command_logs.txt"

Add-Content -Path $logsPath -Value "$(Get-Date -Format "dd/MM/yyyy HH:mm:ss") Running the powershell script to install XDR collectors"

$storageAccountName = "cftptlintsvc"
$storageAccountKey = "${STORAGE_ACCOUNT_KEY}"
$containerName = "xdr-collectors"
$blobName = "windows_x64.msi"
$destinationPath = "C:\Temp\windows_x64.msi"

# Install Azure PowerShell module if not already installed
if (-not (Get-Module -ListAvailable -Name Az.Storage)) {
    Add-Content -Path $logsPath -Value "$(Get-Date -Format "dd/MM/yyyy HH:mm:ss") Installing Az.Storage module"
    Install-Module -Name Az.Storage -AllowClobber -Force -Scope CurrentUser
}

Add-Content -Path $logsPath -Value "$(Get-Date -Format "dd/MM/yyyy HH:mm:ss") Checking storage account access"
# Connect to Azure Storage Account
$context = New-AzStorageContext -StorageAccountName $storageAccountName -StorageAccountKey $storageAccountKey

if ($context) {
    Add-Content -Path $logsPath -Value "$(Get-Date -Format "dd/MM/yyyy HH:mm:ss") Storage account $storageAccountName exists and is accessible"
    # Download the blob (MSI file)
    if (Test-Path $destinationPath) {
        Add-Content -Path $logsPath -Value "$(Get-Date -Format "dd/MM/yyyy HH:mm:ss") file $destinationPath already exists"
    }
    else
    {
        Get-AzStorageBlobContent -Container $containerName -Blob $blobName -Destination $destinationPath -Context $context
    }
    
    # Install the MSI file
    Start-Process -FilePath "msiexec.exe" -ArgumentList "/i $destinationPath /quiet" -NoNewWindow -Wait

    Add-Content -Path $logsPath -Value "$(Get-Date -Format "dd/MM/yyyy HH:mm:ss") XDR Collector installed"

} else {
    Add-Content -Path $logsPath -Value "$(Get-Date -Format "dd/MM/yyyy HH:mm:ss") Storage account $storageAccountName is not accessible"
}
