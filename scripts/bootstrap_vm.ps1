function Install-SplunkUF {
    param
    (
        [Parameter(ValuefromPipeline = $true, Mandatory = $true)] [string]$UF_USERNAME,
        [Parameter(ValuefromPipeline = $true, Mandatory = $true)] [string]$UF_PASSWORD,
        [Parameter(ValuefromPipeline = $true, Mandatory = $true)] [string]$UF_PASS4SYMMKEY,
        [Parameter(ValuefromPipeline = $true, Mandatory = $true)] [string]$UF_GROUP
    )

    # Setup
    $installerURI = 'https://download.splunk.com/products/universalforwarder/releases/8.2.4/windows/splunkforwarder-8.2.4-87e2dda940d1-x64-release.msi'
    $installerFile = $env:Temp + "\splunkforwarder-8.2.4-87e2dda940d1-x64-release.msi"
    $indexServer = 'splunk-cm-prod-vm00.platform.hmcts.net:8089'
    $deploymentServer = 'splunk-lm-prod-vm00.platform.hmcts.net:8089'

    # Downloading & Installing Splunk Universal Forwarder
    Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Downloading Splunk Universal Forwarder installer."
    (New-Object System.Net.WebClient).DownloadFile($installerURI, $installerFile)
    Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Installing Splunk Universal Forwarder."
    Start-Process -FilePath msiexec.exe -ArgumentList "/i $installerFile DEPLOYMENT_SERVER=$deploymentServer RECEIVING_INDEXER=$indexServer WINEVENTLOG_SEC_ENABLE=1 WINEVENTLOG_SYS_ENABLE=0 WINEVENTLOG_APP_ENABLE=0 WINEVENTLOG_FWD_ENABLE=0 WINEVENTLOG_SET_ENABLE=1 AGREETOLICENSE=Yes SERVICESTARTTYPE=AUTO LAUNCHSPLUNK=1 SPLUNKUSERNAME=$UF_USERNAME SPLUNKPASSWORD=$UF_PASSWORD /quiet" -Wait

    # Installation verification
    $splunk = Get-Process -Name "splunkd" -ErrorAction SilentlyContinue
    if ($null -ne $splunk) {
        Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Splunk Universal Forwarder has been installed successfully."
    }
    else {
        Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Splunk Universal Forwarder installation failed."
        exit 1
    }
}

function Install-NessusAgent {
    param
    (
        [Parameter(ValuefromPipeline = $true, Mandatory = $true)] [string]$server,
        [Parameter(ValuefromPipeline = $true, Mandatory = $true)] [string]$key,
        [Parameter(ValuefromPipeline = $true, Mandatory = $true)] [string]$groups
    )

    # Setup
    $installerURI = 'https://www.tenable.com/downloads/api/v1/public/pages/nessus-agents/downloads/16730/download?i_agree_to_tenable_license_agreement=true'
    $installerFile = $env:Temp + "\nessusagent.msi"

    # Download nessus
    Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Downloading Nessus installer."
    (New-Object System.Net.WebClient).DownloadFile($installerURI, $installerFile)

    # Install nessus
    Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Installing Nessus agent."
    Start-Process -FilePath msiexec.exe -ArgumentList "/i $installerFile NESSUS_GROUPS=$groups NESSUS_SERVER=$server NESSUS_KEY=$key /qn" -Wait

    # Installation verification
    $cliPath = Join-Path $env:ProgramFiles -ChildPath "Tenable\Nessus Agent\nessuscli.exe"
    Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Checking CLI path."
    $nessusCli = Test-Path -Path $cliPath -PathType Leaf
    Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Getting agent status."
    if ($nessusCli -ne $False) {
        $nessusStatus = & 'C:\Program Files\Tenable\Nessus Agent\nessuscli.exe' agent status
        $nessusLink = & 'C:\Program Files\Tenable\Nessus Agent\nessuscli.exe' agent link --key=$key --host=$server --port=8834 --groups=$groups
        $agentRunning = $nessusStatus[0]
        $agentLink = $nessusStatus[1]
        Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Nessus agent has been installed successfully."
        Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Nessus agent link output $($nessusLink)."
        Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Nessus agent $($agentRunning)."
        Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Nessus agent $($agentLink)."
    }
    else {
        Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Nessus CLI not found in default location."
        Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Nessus agent installation failed."
    }
}

# Sleep to allow other extensions MSI interactions to complete
Start-Sleep -s 90

if ( "${UF_INSTALL}" -eq "true" ) {
    Install-SplunkUF -UF_USERNAME "${UF_USERNAME}" -UF_PASSWORD "${UF_PASSWORD}" -UF_PASS4SYMMKEY "${UF_PASS4SYMMKEY}" -UF_GROUP "${UF_GROUP}"
}

if ( "${NESSUS_INSTALL}" -eq "true" ) {
    Install-NessusAgent -server "${NESSUS_SERVER}" -key "${NESSUS_KEY}" -groups "${NESSUS_GROUPS}"
}
