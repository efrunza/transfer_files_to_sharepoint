# Variables
  #. '.\00 Variables.ps1'
  #Write-Host "Execute Step 1"

  $RG="EFLogicApp_group"
  #$Subscription="Azure subscription 1"
  #$Location="canadaeast"

  # Deploy RG
  #Write-Host "Execute Step 2"
  #az deployment sub create --location $Location --template-file .\modules\subscription-scope.bicep --parameters RG_Name=$RG location=$Location  

  Write-Host "Execute Step 3"
  # Deployment template to Azure
  az deployment group create --resource-group $RG --template-file main_test.bicep --parameters ./devdeploy.parameters.test.json

  # Write-Host "Execute Step 4"
  # Check deployment result
  # az deployment group show --name main --resource-group testBPRGName2

  # Show result
  Write-Host "Execute Step 5"
  az resource list --resource-group $RG -o table

