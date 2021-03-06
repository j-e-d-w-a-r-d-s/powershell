# Check Free DHCP Reservations
#
# Designed to work with Nagios
#
# Script Usage:
# 
#  PS C:\Users\james.edwards\Desktop\Powershell> .\dhcp-scope.ps1 -Server xxxwindomc01 -ScopeID 172.16.32.0
#  OK - 87.8 % used
# 
#  Warning / Critical default to 90/95 and can be over written by adding -Warning and -Critical
#
# Get a list of DHCP scopes on the local server
# PS C:\Users\james.edwards\Desktop> .\check_dhcp_scope.ps1 -GetScopes
# Available Scopes on localhost :
# 172.16.4.0
# 172.16.12.0
# 172.16.14.0
# 172.16.24.0
# 172.16.25.0
# 172.16.66.0
# 192.168.254.0
# 
# Usage (NSClient):
#
#   1) Place the script in C:\Program Files\NSClient++\Scripts
#   2) Edit C:\Program Files\NSClient++\Scripts\nsclient.ini, and add the following to the section [/settings/external scripts]
#   3) Add the following:
#      check_dhcp_scope=cmd /C echo C:\Progra~1\NSClient++\scripts\dhcp-scope.ps1 -Server "$ARG1$" -ScopeID "$ARG2$" -Warning "$ARG3$" -Critical "$ARG4$"; exit($lastexitcode) | powershell.exe -command -
#
#
# NagioSQL:
# check_dhcp_scope= 
# nagiosql:
#   $USER1$/check_nrpe -H $HOSTADDRESS$ -c check_dhcp_scope -a "$ARG1$" "$ARG2$" "$ARG3$" "$ARG4$" 
#   ARG1=xxxwindomc01
#   ARG2=172.16.32.0
#   ARG3=90
#   ARG4=95

param(
  [string] $Server = "localhost", 
  [string] $ScopeID,
  [switch] $GetScopes = $false,
  [int] $Warning = "90",
  [int] $Critical= "95" 
)

Import-Module DhcpServer

if ($GetScopes) {
  Write-Host "Available Scopes on $Server :"
  $ScopeInfo = Get-DhcpServerv4Scope -ComputerName $Server | select ScopeID
  foreach ( $item in $ScopeInfo.ScopeID) {
    Write-Host $item
  }
  exit
}

if (!$ScopeID) {
  Write-Host "Specify the Scope ID with the -ScopeID switch."
  exit
}

$UsedPercentage = Get-DhcpServerv4ScopeStatistics -ComputerName $Server -ScopeID $ScopeID | select PercentageInUse

$InUse = [math]::Round($UsedPercentage.PercentageInUse,2)

if ($InUse -lt $Warning) { $returncode = 0; $Status = "OK" }
Elseif ($InUse -gt $Warning -and $InUse -lt $Critical) { $returncode = 1; $Status = "WARNING" }
Elseif ($InUse -gt $Critical) { $returncode = 2; $Status = "CRITICAL" }
Else { $returncode = 3; $Status = "UNKNOWN" }
  
Write-Host $Status - "$InUse% used"
exit $returncode
