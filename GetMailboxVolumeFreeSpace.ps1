# GetVolumeFreespace.ps1
#
# Designed to be used to check the free percentage of datastores used in exchange, based on the implementation
# allows you to query any drives by "Label"
#
# If you don't know the Label of the disk, just run:
# PS C:\Users\james.edwards\Documents\PowerShell> .\GetVolumeFreeSpace.ps1 -Server exchangesrv01
# Available disk labels on exchangesrv01
#
# Label
# -----
# System Reserved
# XXXX-MBX01
# XXXX-MBX01
# XXXX-MBX01
# XXXX-MBX01
# ...

# Now that you know the labels, you can run:
#
# PS C:\Users\james.edwards\Documents\PowerShell> .\GetVolumeFreeSpace.ps1 -Server exchangesrv01 -Label XXXX-MBX01
# OK : RW-MBX01 51% Free (126.34GB of 249.91GB available)
# ________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________
# PS C:\Users\james.edwards\Documents\PowerShell> .\GetVolumeFreeSpace.ps1 -Server exchangesrv01 -Label XXXX-MBX01
# WARNING : XXXX-MBX01 8% Free (43.06GB of 549.89GB available)
#
# Alternatively, you can overwrite the default Warning & Critical defaults of 90 & 95
#
# PS C:\Users\james.edwards\Documents\PowerShell> .\GetVolumeFreeSpace.ps1 -Server exchangesrv01 -Label XXXX-MBX01 -Warning 45
# WARNING : XXXX-MBX01 51% Free (126.34GB of 249.91GB available)
#
# PS C:\Users\james.edwards\Documents\PowerShell> .\GetVolumeFreeSpace.ps1 -Server exchangesrv01 -Label XXXX-MBX01 -Warning 95 -Critical 99
# OK : XXXX-MBX01 8% Free (43.06GB of 549.89GB available)
#
# 
 
# Default Options:
param (
  [string]$Server = "$env:COMPUTERNAME",
  [string]$Label = "all",
  [int]$Warning = "90",
  [int]$Critical = "95"
)

function Get-AllLabels ([string]$ComputerName) {
  $volumes = Get-WmiObject -ComputerName $ComputerName -Class win32_volume
  $volumes | Select Label
}

if ($Label -eq "all") {
  Write-Host "Available disk labels on $Server"
  Get-AllLabels -ComputerName $Server
  exit
} Else {
  $Volume = Get-WmiObject -ComputerName $Server -Class win32_volume | where {$_.Label -eq "$Label"}
  $Capacity = $Volume.Capacity / 1GB
  $FreeSpace = $Volume.FreeSpace / 1GB
  $UsedSpace = ($Volume.Capacity - $Volume.FreeSpace) / 1GB

  $PercentFree = [Math]::Round(($Volume.FreeSpace / $Volume.Capacity) * 100)
  $PercentUsed = 100 - [Math]::Round(($Volume.FreeSpace / $Volume.Capacity) * 100)

  #Write-Host $UsedSpace, $Capacity, $FreeSpace, $PercentFree, $PercentUsed

  If ($PercentUsed -lt $Warning) { $returncode = 0; $Status = "OK" }
  ElseIF ($PercentUsed -gt $Warning -and $PercentUsed -lt $Critical) {$returncode = 1; $Status = "WARNING"} 
  ElseIf ($PercentUsed -gt $Critical) {$returncode = 2; $Status = "CRITICAL"}

  "$Status : $Label $PercentUsed% Used (" + [System.Math]::Round($FreeSpace, 2) + "GB of " + [System.Math]::Round($Capacity, 2) + "GB available)"
  exit $returncode
}
