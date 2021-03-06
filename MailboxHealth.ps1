# Test Mailbox Database and Content Index Health
# Replace Servernames to match host
# Place in C:\scripts\ folder and edit nsc.ini to call "check_mb_servername=cmd /c echo C:\Scripts\MailboxHealth-servername.ps1 ; exit($lastexitcode) | PowerShell.exe -Command -"

param([string] $Server)

Add-PSSnapin Microsoft.Exchange.Management.PowerShell.E2010
 
$Status = Get-MailboxDatabaseCopyStatus -server $server
 
$flag1 = 0
 
foreach($State in $Status){
  if(($state.status -match '^Mounted') -or ($state.status -match '^Healthy')) {
  }else{
    $content = $($state.name)+": "+$($state.status)
	$output += $content+" - "
	$flag2 =1
  } 
}

foreach($ContentIndexState in $Status){
  if($ContentIndexState.contentindexstate -match '^Healthy') {
  }else{
	$content2 = $($ContentIndexState.name)+" Index: "+$($ContentIndexState.contentindexstate)
	$output2 += $content2+" - "
	$flag3 = 2
  }
}

$flag = $flag1 + $flag2 + $flag3	
 
if($flag -eq 0){
  write-host "All Databases and Indexes OK"
  exit 0
} elseif ($flag -eq 1){
  write-host $output 
  exit 2
} elseif ($flag -eq 2){
  write-host $output2
  exit 1
} elseif ($flag -eq 3){
  write-host $output $output2
  exit 2
}