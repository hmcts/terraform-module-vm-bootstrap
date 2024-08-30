function Install-CIS {

    #instal choco

    Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

    # Install choco packages

    choco install powershell-core -y

    #Installing new version of Powershell and modules and packages

    Start-Process powershell -Verb runAs -Wait -ArgumentList  "-command Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/hmcts/CIS-harderning/master/windows-install.ps1'))"

    #run the CIS hardening powershell script

    #Check OS version to run relevant script
    $OSVersion = (get-itemproperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion" -Name ProductName).ProductName

    If($OSVersion -eq "Windows Server 2019 Datacenter")
    {
        Start-Process pwsh.exe -Wait -ArgumentList "-command Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/hmcts/CIS-harderning/master/windows2019.ps1'))"
    }
    ElseIf($OSVersion -eq "Windows Server 2016")
    {
            Write-Output "do nothing"
    }
    #apply script
    Start-Process pwsh.exe -Wait -ArgumentList  "-command Start-DscConfiguration -Path .\CIS_Benchmark_WindowsServer2019_v100  -Force -Verbose -Wait"

}



function Install-XDR {
    # Define parameters

    $logsPath = "C:\Packages\Plugins\run_command_logs.txt"

    Add-Content -Path $logsPath -Value "$(Get-Date -Format "dd/MM/yyyy HH:mm:ss") Running the powershell script to install XDR collector"

    $storageAccountName = "cftptlintsvc"
    $storageAccountKey = "${STORAGE_ACCOUNT_KEY}"
    $containerName = "xdr-collectors"
    $blobName = "${ENV}/collector-windows_x64.msi"
    $destinationPath = "C:\Temp\windows_x64.msi"
    $tempFolder= "C:\Temp"

    # Install Azure PowerShell module if not already installed
    if (-not (Get-Module -ListAvailable -Name Az.Storage)) {
        Add-Content -Path $logsPath -Value "$(Get-Date -Format "dd/MM/yyyy HH:mm:ss") Installing Az.Storage module"
        Install-PackageProvider -Name NuGet -Force -Scope CurrentUser
        Install-Module -Name Az.Storage -AllowClobber -Force -Scope CurrentUser
        Add-Content -Path $logsPath -Value "$(Get-Date -Format "dd/MM/yyyy HH:mm:ss") Finish Installing Az.Storage module"
    }

    # Connect to Azure Storage Account
    if ([string]::IsNullOrEmpty($storageAccountKey)) {
        Write-Error "Storage account key is null or empty. Please provide a valid key."
        Add-Content -Path $logsPath -Value "$(Get-Date -Format "dd/MM/yyyy HH:mm:ss") Storage account key is null or empty. Please provide a valid key"
        exit 1
    }

    try {
        # Create a new storage context
        $context = New-AzStorageContext -StorageAccountName $storageAccountName -StorageAccountKey $storageAccountKey
        
        # Test the context by listing containers
        $containers = Get-AzStorageContainer -Context $context -ErrorAction Stop
        Write-Output "Successfully created storage context."
        Add-Content -Path $logsPath -Value "$(Get-Date -Format "dd/MM/yyyy HH:mm:ss") Successfully created storage context"
    } catch {
        Add-Content -Path $logsPath -Value "$(Get-Date -Format "dd/MM/yyyy HH:mm:ss") Failed to create storage context. Please check the storage account name and key"
        Write-Error "Failed to create storage context. Please check the storage account name and key."
        exit 1
    }


    if ($context) {
        Add-Content -Path $logsPath -Value "$(Get-Date -Format "dd/MM/yyyy HH:mm:ss") Storage account $storageAccountName exists and is accessible"
        # Download the blob (MSI file)

        # Check if the folder exists, if not, create it
        if (-Not (Test-Path -Path $tempFolder -PathType Container)) {
            Add-Content -Path $logsPath -Value "$(Get-Date -Format "dd/MM/yyyy HH:mm:ss") Creating $tempFolder folder"
            New-Item -Path $tempFolder -ItemType Directory
            Write-Output "Folder created: $tempFolder"
            
        } else {
            Add-Content -Path $logsPath -Value "$(Get-Date -Format "dd/MM/yyyy HH:mm:ss") $tempFolder folder exist"
            Write-Output "Folder already exists: $tempFolder"
        }
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

}
function Install-AGENT {
    # Define parameters

    $logsPath = "C:\Packages\Plugins\run_command_logs.txt"

    Add-Content -Path $logsPath -Value "$(Get-Date -Format "dd/MM/yyyy HH:mm:ss") Running the powershell script to install XDR Agent"

    $storageAccountName = "cftptlintsvc"
    $storageAccountKey = "${STORAGE_ACCOUNT_KEY}"
    $containerName = "xdr-collectors"
    $blobName = "${ENV}/${ENV}_agent-HMCTS_Windows_x64_agent.msi"
    $destinationPath = "C:\Temp\Cortex_XDR_8_4_0\HMCTS_Windows_x64_agent.msi"

    $tempFolder= "C:\Temp"
    $agentLogPath = "C:\Temp\Cortex_XDR_8_4_0\xdr_install.txt"
    $folderPath = "C:\Temp\Cortex_XDR_8_4_0"
    $endpointTags = "${XDR_TAGS}"

    $arguments = "/i `"$destinationPath`" /qn /l*v `"$agentLogPath`" ENDPOINT_TAGS=`"$endpointTags`""

    # Install Azure PowerShell module if not already installed
    if (-not (Get-Module -ListAvailable -Name Az.Storage)) {
        Add-Content -Path $logsPath -Value "$(Get-Date -Format "dd/MM/yyyy HH:mm:ss") Installing Az.Storage module"
        Install-PackageProvider -Name NuGet -Force -Scope CurrentUser
        Install-Module -Name Az.Storage -AllowClobber -Force -Scope CurrentUser
        Add-Content -Path $logsPath -Value "$(Get-Date -Format "dd/MM/yyyy HH:mm:ss") Finish Installing Az.Storage module"
    }

    # Connect to Azure Storage Account
    if ([string]::IsNullOrEmpty($storageAccountKey)) {
        Write-Error "Storage account key is null or empty. Please provide a valid key."
        Add-Content -Path $logsPath -Value "$(Get-Date -Format "dd/MM/yyyy HH:mm:ss") Storage account key is null or empty. Please provide a valid key"
        exit 1
    }

    try {
        # Create a new storage context
        $context = New-AzStorageContext -StorageAccountName $storageAccountName -StorageAccountKey $storageAccountKey
        
        # Test the context by listing containers
        $containers = Get-AzStorageContainer -Context $context -ErrorAction Stop
        Write-Output "Successfully created storage context."
        Add-Content -Path $logsPath -Value "$(Get-Date -Format "dd/MM/yyyy HH:mm:ss") Successfully created storage context"
    } catch {
        Add-Content -Path $logsPath -Value "$(Get-Date -Format "dd/MM/yyyy HH:mm:ss") Failed to create storage context. Please check the storage account name and key"
        Write-Error "Failed to create storage context. Please check the storage account name and key."
        exit 1
    }


    if ($context) {


         # Check if the folder exists, if not, create it
         if (-Not (Test-Path -Path $tempFolder -PathType Container)) {
            Add-Content -Path $logsPath -Value "$(Get-Date -Format "dd/MM/yyyy HH:mm:ss") Creating $tempFolder folder"
            New-Item -Path $tempFolder -ItemType Directory
            Write-Output "Folder created: $tempFolder"
            
        } else {
            Add-Content -Path $logsPath -Value "$(Get-Date -Format "dd/MM/yyyy HH:mm:ss") $tempFolder folder exist"
            Write-Output "Folder already exists: $tempFolder"
        }

         # Check if the folder exists, if not, create it
         if (-Not (Test-Path -Path $folderPath -PathType Container)) {
            Add-Content -Path $logsPath -Value "$(Get-Date -Format "dd/MM/yyyy HH:mm:ss") Creating $folderPath folder"
            New-Item -Path $folderPath -ItemType Directory
            Write-Output "Folder created: $folderPath"
            
        } else {
            Add-Content -Path $logsPath -Value "$(Get-Date -Format "dd/MM/yyyy HH:mm:ss") $folderPath folder exist"
            Write-Output "Folder already exists: $folderPath"
        }

        # Check if the file exists, if not, create it
        if (-Not (Test-Path -Path $agentLogPath -PathType Leaf)) {
            Add-Content -Path $logsPath -Value "$(Get-Date -Format "dd/MM/yyyy HH:mm:ss") Temp folder exist"
            New-Item -Path $agentLogPath -ItemType File
            Write-Output "File created: $agentLogPath"
        } else {
            Add-Content -Path $logsPath -Value "$(Get-Date -Format "dd/MM/yyyy HH:mm:ss") File already exists: $agentLogPath"
            Write-Output "File already exists: $agentLogPath"
        }
        
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
        Start-Process -FilePath "msiexec.exe" -ArgumentList $arguments -NoNewWindow -Wait

        Add-Content -Path $logsPath -Value "$(Get-Date -Format "dd/MM/yyyy HH:mm:ss") XDR Agent installed"

    } else {
        Add-Content -Path $logsPath -Value "$(Get-Date -Format "dd/MM/yyyy HH:mm:ss") Storage account $storageAccountName is not accessible"
    }

}

if ( "${RUN_CIS}" -eq "true" ) {
    Install-CIS
}

if ( "${RUN_XDR_COLLECTOR}" -eq "true" ) {
    Install-XDR
}

if ( "${RUN_XDR_AGENT}" -eq "true" ) {
    Install-AGENT
}