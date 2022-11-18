
#Installing new version of Powershell and modules and packages

Start-Process powershell -Wait -ArgumentList  "-command Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/hmcts/CIS-harderning/master/windows-install.ps1'))"


#run the CIS hardening powershell script


Start-Process pwsh.exe -Wait -ArgumentList "-command Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/hmcts/CIS-harderning/master/windows2019.ps1'))"

#apply script
Start-Process pwsh.exe -Wait -ArgumentList  "-command Start-DscConfiguration -Path .\CIS_Benchmark_WindowsServer2019_v100  -Force -Verbose -Wait"