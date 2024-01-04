# MS365HardMatching

## Description

This PowerShell script synchronizes the ImmutableID attribute between a user's Active Directory account and their Microsoft 365 account. This ensures proper synchronization between the two systems.

## Key Features

Validates the existence of required PowerShell modules (MSOnline and ActiveDirectory)
Prompts for user input to specify the EntraID UPN and Active Directory Sam Account Name
Performs validation checks to ensure the user accounts exist in both systems
Retrieves relevant user information from Active Directory
Connects to Microsoft 365 and updates the user's ImmutableID
Provides clear logging for troubleshooting
## Prerequisites

PowerShell 5.1 or later
MSOnline PowerShell module installed: Install-Module -Name ExchangeOnlineManagement
ActiveDirectory PowerShell module installed (either through RSAT tools or running from a Domain Controller)
## Usage Instructions

Save the script as a .ps1 file.

Open a PowerShell window with administrative privileges.

Run the script using the following command:

PowerShell
.\HardMarching.ps1
Use code with caution. Learn more
Follow the prompts to enter the required user information.

## Logging

The script creates a log file at %windir%\Temp\Logs\HardMarching.log to track its progress and any errors encountered.

## Additional Notes

The script includes retry logic for invalid user input.
The script terminates any existing PowerShell sessions before exiting.
## Author

Warren Sherwen

## Version

1.0

## Disclaimer

Use this script at your own risk. It is recommended to test the script in a non-production environment before deploying it in a production environment.

## Contributing

Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.
