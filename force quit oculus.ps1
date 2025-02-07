# # Check if the script is running as Administrator
# $CurrentIdentity = [Security.Principal.WindowsIdentity]::GetCurrent()
# $Principal = New-Object Security.Principal.WindowsPrincipal($CurrentIdentity)
# $IsAdmin = $Principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

# if (-not $IsAdmin) {
#     # If not running as admin, restart the script as admin
#     # This doesn't work properly, regardless of PS5 (`powershell`) or PS7 (`pwsh`)
#     Start-Process pwsh -Verb runAs -ArgumentList "-File", $MyInvocation.MyCommand.Path
#     exit
# }

Get-Process | ? { $_.Path -match "oculus" } | Stop-Process -Force