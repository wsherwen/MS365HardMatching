# Author: Warren Sherwen
# Last Edit: Warren Sherwen
# Verison: 1.0

$Logfile = "$env:windir\Temp\Logs\HardMarching.log"
Function LogWrite{
   Param ([string]$logstring)
   Add-content $Logfile -value $logstring
   write-output $logstring
   
}
function Get-TimeStamp {
    return "[{0:dd/MM/yy} {0:HH:mm:ss}]" -f (Get-Date)
}

if (!(Test-Path "$env:windir\Temp\Logs\"))
{
   mkdir $env:windir\Temp\Logs\
   LogWrite "$(Get-TimeStamp): Script has started."
   LogWrite "$(Get-TimeStamp): Log directory created."
}
else
{
    LogWrite "$(Get-TimeStamp): Script has started."
    LogWrite "$(Get-TimeStamp): Log directory exists."
}

#PowerShell prechecks
LogWrite "$(Get-TimeStamp): Checking if MSOnline is installed."
if (!(Get-Module -ListAvailable -Name MSOnline)) {
    LogWrite "$(Get-TimeStamp): MSOnline Module not installed."
    LogWrite "$(Get-TimeStamp): Please run: Install-Module -Name ExchangeOnlineManagement."
    LogWrite "$(Get-TimeStamp): Script ending, powershell closing..."
    Exit
}

LogWrite "$(Get-TimeStamp): MSOnline Module found."

if (!(Get-Module -ListAvailable -Name ActiveDirectory)) {
    LogWrite "$(Get-TimeStamp): ActiveDirectory Module not installed."
    LogWrite "$(Get-TimeStamp): Please install RSAT Tools or Run from a Domain Controller."
    LogWrite "$(Get-TimeStamp): Script ending, powershell closing..."
    Exit
}

LogWrite "$(Get-TimeStamp): ActiveDirectory Module found."
LogWrite "$(Get-TimeStamp): No further checks required."

#User Parameters
LogWrite "$(Get-TimeStamp): Collecting the EntraID UPN."
$Microsoft365Users = Read-Host -Prompt 'Enter the EntraID UPN'
LogWrite "$(Get-TimeStamp): User entered: $Microsoft365Users."

LogWrite "$(Get-TimeStamp): Collecting the Active Directory User Sam Account Name"
$ADAccount = Read-Host -Prompt 'Enter the Active Directory Users Sam Account Name'
LogWrite "$(Get-TimeStamp): User entered: $ADAccount."

LogWrite "$(Get-TimeStamp): Importing ActiveDirectory Module."
Import-Module -name ActiveDirectory

$ADAccount = Read-Host -Prompt 'Enter the Active Directory Users Sam Account Name'

LogWrite "$(Get-TimeStamp): Collecting data from Active Directory."
$validateADUser = Get-ADUser -Identity $ADAccount -ErrorAction SilentlyContinue

$retryLimit = 3
$retryCount = 0

LogWrite "$(Get-TimeStamp): Valadting the user exists in Active Directory."
if ($validateADUser.SamAccountName -ne $ADAccount) {
    do {
        if ($retryCount -gt 0) {
            LogWrite "$(Get-TimeStamp): The user account supplied was invalid."
            Write-Host "The user account entered was invalid, request to retry being captured."
        }

        LogWrite "$(Get-TimeStamp): Requesting Sam Account Name is retyped."
        $ADAccount = Read-Host "Retype the AD Sam Account Name"
        LogWrite "$(Get-TimeStamp): Valadting the Sam Account Name exists in AD."
        $validateADUser = Get-ADUser -Identity $ADAccount -ErrorAction SilentlyContinue

        if ($validateADUser) {
            Write-Host "The user account was found."
            LogWrite "$(Get-TimeStamp): The user account was found."
            break
        } else {
            Write-Host "The user account was not found."
            LogWrite "$(Get-TimeStamp): Retried Sam Account Name not found."
        }

        $retryCount++
    } while ($retryCount -le $retryLimit)

    if ($retryCount -gt $retryLimit) {
        LogWrite "$(Get-TimeStamp): Maxium retries has been met, exiting script."
        Write-Host "Maxium amount of retries atempted. The script is exiting..."
        Exit
    }
}

$ADObject = Get-ADUser -Identity $ADAccount | Select-Object UserPrincipalName, objectGUID, @{Name = 'ImmutableID'; Expression = { [System.Convert]::ToBase64String(([GUID]$_.objectGUID).ToByteArray()) } }


Import-Module -name MSOnline
Connect-MsolService

LogWrite "$(Get-TimeStamp): Collecting data from Microsoft365."
$validateMS365User = Get-MsolUser -UserPrincipalName $Microsoft365Users -ErrorAction SilentlyContinue

$retryLimit = 3
$retryCount = 0

LogWrite "$(Get-TimeStamp): Valadting the user exists in MS365."
if ($validateMS365User.UserPrincipalName -ne $Microsoft365Users) {
    do {
        if ($retryCount -gt 0) {
            LogWrite "$(Get-TimeStamp): The upn address supplied was invalid."
            Write-Host "The upn entered was invalid, request to retry being captured."
        }

        LogWrite "$(Get-TimeStamp): Requesting upn address is retyped."
        $Microsoft365Users = Read-Host "Retype the users MS365 UPN"
        LogWrite "$(Get-TimeStamp): Valadting the upn exists MS365."
        $validateMS365User = Get-MsolUser -UserPrincipalName $Microsoft365Users -ErrorAction SilentlyContinue

        if ($validateMS365User) {
            Write-Host "The user was found."
            LogWrite "$(Get-TimeStamp): The user was found."
            break
        } else {
            Write-Host "The user was not found."
            LogWrite "$(Get-TimeStamp): Retried upn not found."
        }

        $retryCount++
    } while ($retryCount -le $retryLimit)

    if ($retryCount -gt $retryLimit) {
        LogWrite "$(Get-TimeStamp): Maxium retries has been met, exiting script."
        Write-Host "Maxium amount of retries atempted. The script is exiting..."
        Exit
    }
}

Set-MsolUser -UserPrincipalName $Microsoft365Users -ImmutableID $ADObject.ImmutableID
$MS365UserResult = Get-MsolUser -UserPrincipalName $Microsoft365Users 

if ($MS365UserResult.ImmutableID = $ADObject.ImmutableID) {
    Wrtie-Host "ImmutableID has been updated: $MS365UserResult.ImmutableID"
     }
    else { 
        write-Host "Failed to update the users ImmutableID. Current ImmutableID: $MS365UserResult.ImmutableID"
    }
}

LogWrite "$(Get-TimeStamp): Script ending, powershell closing..."
#Terminate the session
Get-PSSession | Remove-PSSession

#Terminates the Script
Read-Host -Prompt "Press Enter to exit"
Exit