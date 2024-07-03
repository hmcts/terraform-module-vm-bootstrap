# Define parameters


Add-Content -Path C:\Temp\logs.txt -Value "$(Get-Date -Format "dd/MM/yyyy HH:mm:ss") this is test: ${arg1}"
# $storageAccountName = "cftptlintsvc"
# $storageAccountKey = "${STORAGE_ACCOUNT_KEY}"
# $containerName = "xdr-collectors"
# $blobName = "windows_x64.msi"
# $destinationPath = "C:\Temp\windows_x64.msi"

# # Install Azure PowerShell module if not already installed
# if (-not (Get-Module -ListAvailable -Name Az)) {
#     Install-Module -Name Az -AllowClobber -Force -Scope CurrentUser
# }

# # Connect to Azure Storage Account
# $context = New-AzStorageContext -StorageAccountName $storageAccountName -StorageAccountKey $storageAccountKey

# # Download the blob (MSI file)
# Get-AzStorageBlobContent -Container $containerName -Blob $blobName -Destination $destinationPath -Context $context

# # Install the MSI file
# Start-Process -FilePath "msiexec.exe" -ArgumentList "/i $destinationPath /quiet" -Wait
