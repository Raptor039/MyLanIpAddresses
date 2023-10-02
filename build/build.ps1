$scriptPath = Split-Path $PSScriptRoot -Parent
try {
# Check presence of ps2exe module, install if not present
    if(!(Get-Module ps2exe)) {
        Install-Module ps2exe
    }
}
catch {
    Write-Output "Something went wrong with installing module"
}

try {
# Build script to exe
    $ExeName = "MyLanIpAddresses"
    $ExeVersion = "1.0"
    $icoFileName = "adresse-ip"
    $Title = "My LAN IP Addresses"
    $Product = $Title
    $Description = "Display informations about LAN IP addresses (v4 and v6) for all active network adapters presents on the device"
    $Company = "Raptor039"

    Invoke-ps2exe -inputFile "$($scriptPath)\src\MyLanIpAdresses.ps1" -outputFile "$($scriptPath)\build\$($ExeName).exe" -iconFile "$($scriptPath)\src\$($icoFileName).ico" -noConsole -title $Title -product $Product -description $Description -company $Company -version $ExeVersion -exitOnCancel -noOutput -noError -UNICODEEncoding -DPIAware
}
catch {
    Write-Output "Something went wrong with building module"
}



