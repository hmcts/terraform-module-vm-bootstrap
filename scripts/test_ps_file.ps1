New-Item -Path c:\windows\TestFolder -ItemType Directory | Out-File -filepath test_ps_file.ps1

Install-Module -Name AuditPolicyDsc -force
Install-Module -Name SecurityPolicyDsc -force
Install-Module -Name NetworkingDsc -force
Install-Module -Name PSDesiredStateConfiguration -force