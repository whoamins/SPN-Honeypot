$secureString = ConvertTo-SecureString -AsPlainText -Force 
$userPassword = ConvertFrom-SecureString $secureString
$userPassword | Set-Content -Path 'C:\Users\Administrator\Desktop\password.txt'