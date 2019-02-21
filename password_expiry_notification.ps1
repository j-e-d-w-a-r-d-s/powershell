# Days to Password Expiry
$days_before_expiry = 14

# SMTP Server to be used
$smtp = "mail.saperavi.local"

# Administrator email
$admin = "james.edwards@bsdftw.org"

$today = (Get-date)

Import-Module ActiveDirectory

function SendEmail {
  param(
    [string]$To,
    [string]$From,
    [string]$Subject
  )

  Send-MailMessage `
    -To $To `
    -From $From `
    -Bcc $admin `
    -Subject $Subject `
    -Body "If you have access to a Windows machine, you can change your password there, otherwise contact Help Desk to reset your password." `
    -SmtpServer $smtp
}

# use the sAMAccountName here, we'll look up the primary email address
$users = @("first.last", "first.last", "first.last", "first.last")

foreach ($user in $users) {
  # Loop through, get the display name and expiry date for the account
  $GetUserInfo = Get-ADUser `
    -Filter 'SamAccountName -like $user' `
    -Properties "DisplayName", "msDS-UserPasswordExpiryTimeComputed","mail" `
    -Server saperavi.local `
    | Select-Object -Property "Displayname",@{Name="ExpiryDate";Expression={[datetime]::FromFileTime($_."msDS-UserPasswordExpiryTimeComputed")}},"mail" | Sort-Object ExpiryDate
  $days_remaining = ($GetUserInfo.ExpiryDate - $today).days

  # If our users have less than $days_remaining, send them an email:
  if ($days_remaining -le $days_before_expiry -And $days_remaining -gt 0) {
    Write-Host "Sending email to:" $GetUserInfo.DisplayName "with" $days_remaining
    SendEmail -To $GetUserInfo.mail -From $GetUserInfo.mail -Subject "Your password will expire in $days_remaining days"
 
  }  

}

