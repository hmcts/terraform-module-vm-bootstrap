New-Item -Path c:\windows\TestFolder -ItemType Directory | Out-File -filepath test_ps_file.ps1

Install-Module -Name AuditPolicyDsc
Install-Module -Name SecurityPolicyDsc
Install-Module -Name NetworkingDsc
Install-Module -Name PSDesiredStateConfiguration