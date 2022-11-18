$installfromgit = Invoke-WebRequest https://raw.githubusercontent.com/hmcts/CIS-harderning/master/windows-install.ps1
Invoke-Expression $($installfromgit.Content)


invoke-expression 'cmd /c start pwsh.exe -Command { 
cd $home
$ScriptFromGitHub = Invoke-WebRequest https://raw.githubusercontent.com/hmcts/CIS-harderning/master/windows2019.ps1;
Invoke-Expression "& {$($ScriptFromGitHub.Content)}"}'

invoke-expression 'cmd /c start pwsh.exe -Command { 
cd $home
Start-DscConfiguration -Path .\CIS_Benchmark_WindowsServer2019_v100  -Force -Verbose -Wait}'