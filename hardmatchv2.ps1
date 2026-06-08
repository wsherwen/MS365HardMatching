param(
    [Parameter(Mandatory=$true)]
    [string]$UserPrincipalName
)


Connect-MgGraph -Scopes "User.ReadWrite.All","Directory.ReadWrite.All"
Import-Module ActiveDirectory

$ADUser = Get-ADUser -Filter {UserPrincipalName -eq $UserPrincipalName} -Properties ObjectGUID

$ImmutableId = [System.Convert]::ToBase64String($ADUser.ObjectGUID.ToByteArray())

$CloudUser = Get-MgUser -UserId $UserPrincipalName

Update-MgUser -UserId $CloudUser.Id -OnPremisesImmutableId $ImmutableId
param(
    [Parameter(Mandatory=$true)]
    [string]$UserPrincipalName
)

Connect-MgGraph -Scopes "User.ReadWrite.All","Directory.ReadWrite.All"

Import-Module ActiveDirectory

$ADUser = Get-ADUser -Filter {UserPrincipalName -eq $UserPrincipalName} -Properties ObjectGUID

$ImmutableId = [System.Convert]::ToBase64String($ADUser.ObjectGUID.ToByteArray())

$CloudUser = Get-MgUser -UserId $UserPrincipalName

Update-MgUser -UserId $CloudUser.Id -OnPremisesImmutableId $ImmutableId
Write-Output "$UserPrincipalName hard matched with ImmutableId $ImmutableId"
