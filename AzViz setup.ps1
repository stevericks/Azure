install-module -name AzViz
install-module -name Az
Import-Module AzViz
Connect-AzAccount
Select-AzSubscription "sub-fgh-financier-prd"
Export-AzViz -ResourceGroup rg-rti-uks-financier-prd -Theme light -OutputFormat svg -show