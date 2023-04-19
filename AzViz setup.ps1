# chocolatey packages Graphviz for Windows
choco install graphviz

# alternatively using windows package manager
winget install graphviz


#Installation
#From PowerShell Gallery

# install from powershell gallery
Install-Module AzViz -Verbose -Scope CurrentUser -Force

# import the module
Import-Module AzViz -Verbose

# login to azure, this is required for module to work
Connect-AzAccount



install-module -name AzViz
install-module -name Az
Import-Module AzViz
Connect-AzAccount
Select-AzSubscription "sub-fgh-financier-prd"
Export-AzViz -ResourceGroup rg-rti-uks-financier-prd -Theme light -OutputFormat svg -show
