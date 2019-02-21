# Checks to make sure the GoAnywhere process is running

$GoAnywhere = Get-Process tomcat -ErrorAction SilentlyContinue
$LogTime = Get-Date
$LogFile = "C:\Watchdog\watchdog.log"
$Hostname = $env:computername

if (! $GoAnywhere) {
  # Tomcat process not found...
  Get-Service -Name GoAnywhere | Start-Service
  # Write an entry to our log
  "$Hostname - $LogTime - GoAnywhere restarted by watchdog " | Out-File $LogFile -Append -Force
}