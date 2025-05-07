function Remove-SplunkUF {
    $serviceName = "SplunkForwarder"
    $splunkService = Get-Service -Name $serviceName -ErrorAction SilentlyContinue
    $uninstallerURI = 'https://download.splunk.com/products/universalforwarder/releases/9.3.1/windows/splunkforwarder-9.3.1-0b8d769cb912-x64-release.msi'
    $uninstallerFile = "C:\Temp\splunkforwarder.msi"

    if ($splunkService) {
        if (-not (Test-Path $uninstallerFile)) {
            Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Downloading Splunk uninstaller."
            (New-Object System.Net.WebClient).DownloadFile($uninstallerURI, $uninstallerFile)
        }

        Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) SplunkForwarder service found. Uninstalling."
        $splunkHome = "C:\Program Files\SplunkUniversalForwarder"
        $splunkBinPath = "$splunkHome\bin"

        if (Test-Path $splunkBinPath) {
            Push-Location $splunkBinPath
            try { .\splunk stop; Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Splunk stopped." } catch { Write-Host "$_"; Pop-Location; return }
            Pop-Location
        } else {
            Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Splunk bin path not found. Continuing to uninstall."
        }

        try {
            Start-Process "msiexec.exe" -ArgumentList "/x $uninstallerFile /qn" -Wait -NoNewWindow
            Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Splunk uninstalled."
        } catch { Write-Host "$_"; return }
    } else {
        Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) SplunkForwarder service not found. No action taken."
    }
}
function Get-DownloadId {
    param(
      [string]$desc
    )
    # use Invoke-RestMethod to get the JSON data from the web url

    $url = "https://www.tenable.com/downloads/api/v1/public/pages/nessus-agents/"
    $response = Invoke-WebRequest -Uri $url -UseBasicParsing
    
    $json_data = $response.Content
    # use ConvertFrom-Json to convert the JSON data to a PowerShell object
    $json_object = $json_data | ConvertFrom-Json
    # use a filter expression to select the id property of the objects that match the description

    $download_id = $json_object.downloads | Where-Object {$_.description -eq $desc} | Select-Object -ExpandProperty id
    # use Sort-Object and Select-Object to get the highest id value
    $highest = $download_id | Sort-Object | Select-Object -Last 1
    # write the output to the pipeline
    Write-Output $highest
  }

function Install-NessusAgent {
    param
    (
        [Parameter(ValuefromPipeline = $true, Mandatory = $true)] [string]$server,
        [Parameter(ValuefromPipeline = $true, Mandatory = $true)] [string]$key,
        [Parameter(ValuefromPipeline = $true, Mandatory = $true)] [string]$groups
    )

    # Setup
    $id = Get-DownloadId -desc "Windows Server 2012, Server 2012 R2, Server 2016, Server 2019, Server 2022, 10, and 11 (x86_64)"
    $installerURI = "https://www.tenable.com/downloads/api/v2/pages/nessus-agents/files/NessusAgent-latest-x64.msi"
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

# Exit on error
$ErrorActionPreference = "Stop"

if ( "${UF_REMOVE}" -eq "true" ) {
    Remove-SplunkUF
}

if ( "${NESSUS_INSTALL}" -eq "true" ) {
    Install-NessusAgent -server "${NESSUS_SERVER}" -key "${NESSUS_KEY}" -groups "${NESSUS_GROUPS}"
}
