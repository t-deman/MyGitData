Add-Type -AssemblyName System.Web

$dom=(Get-MsolDomain  |where { $_.isdefault }).name

$pass1=[System.Web.Security.Membership]::GeneratePassword(64,4)
$pass2=[System.Web.Security.Membership]::GeneratePassword(64,4)

$name=-join ((97..122) | Get-Random -Count 64 | % {[char]$_})
echo $pass1 >${Name}Pass1.txt
echo $pass2 >${Name}Pass2.txt

$UPN="$name@$dom"
echo "Creation of account : $UPN"
$DisplayName="BreakGlass $name"
$Password="$pass1$pass2"

#echo $password

$NewUser=New-MsolUser -UserPrincipalName $UPN -DisplayName $DisplayName -ForceChangePassword $false -StrongPasswordRequired $true -Password $Password -PasswordNeverExpires $true 
echo $Newuser.DisplayName
