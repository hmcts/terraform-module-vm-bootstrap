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