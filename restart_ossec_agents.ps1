
$ServerList = @("172.17.224.20",
  "172.17.224.21",
  "172.17.224.22",
  "172.17.224.23",
  "172.17.224.24",
  "172.17.224.25",
  "172.17.224.26",
  "172.17.224.27",
  "172.17.224.28",
  "172.17.224.29",
  "172.17.224.30",
  "172.17.224.31",
  "172.17.224.32",
  "172.17.224.33",
  "172.17.224.35",
  "172.17.224.36"
)

foreach($Server in $ServerList){
  Write-Host $Server
  #Get-Service -Name OssecSvc -ComputerName $Server | Stop-Service
  Get-Service -Name OssecSvc -ComputerName $Server
  #Get-Service -Name OssecSvc -ComputerName $Server | Start-Service
}