param vmName string
param location string = 'UK South'
param vmSize string = 'Standard_B2ms' 
param AdminUsername string
@secure()
param AdminPassword string
param domainJoinUserName string
@secure()
param domainJoinUserPassword string

resource myDataDisk 'Microsoft.Compute/disks@2022-07-02' = {
  name: '${vmName}-DataDisk'
  location: location
  properties: {
    diskSizeGB: 32
    creationData: {
      createOption: 'Empty'
    }
    diskIOPSReadWrite: 500
    diskMBpsReadWrite: 20
    osType: 'Windows'
  }
}

resource myNetworkInterface 'Microsoft.Network/networkInterfaces@2022-07-01' = {
  name: '${vmName}-nic'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: resourceId('rg-network-uks-financier-non-prd','Microsoft.Network/virtualNetworks/subnets','vnet-fgh-uks-financier-non-prd','snet-developement')
          }
        }
      }
    ]
  }
}

resource myVirtualMachine 'Microsoft.Compute/virtualMachines@2022-11-01' = {
  name: vmName
  location: location
  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }
    storageProfile: {
      imageReference: {
        publisher: 'MicrosoftWindowsServer'
        offer: 'WindowsServer'
        sku: '2019-datacenter-gensecond'
        version: 'latest'
      }
      osDisk: {
        osType: 'Windows'
        name: '${vmName}_OsDisk'
        createOption: 'FromImage'
        caching: 'ReadWrite'
        managedDisk: {
          storageAccountType: 'Standard_LRS'
        }
        deleteOption: 'Detach'
      }
      dataDisks: [
        {
          lun: 0
          name: '${vmName}-DataDisk'
          createOption: 'Attach'
          caching: 'None'
          diskSizeGB: 1024
          writeAcceleratorEnabled: false
          managedDisk: {
            id: myDataDisk.id
          }
          deleteOption: 'Detach'
          toBeDetached: false
        }
      ]
    }
    osProfile: {
      computerName: vmName
      adminUsername: AdminUsername
      adminPassword: AdminPassword
      windowsConfiguration: {
        provisionVMAgent: true
        enableAutomaticUpdates: true
        patchSettings: {
          patchMode: 'AutomaticByOS'
          assessmentMode: 'ImageDefault'
        }
        enableVMAgentPlatformUpdates: false
      }
      secrets: []
      allowExtensionOperations: true
      }
    networkProfile: {
      networkInterfaces: [
        {
          id: myNetworkInterface.id
        }
      ]
    }
  }
}

resource virtualMachineExtension 'Microsoft.Compute/virtualMachines/extensions@2021-03-01' = {
    parent: myVirtualMachine
    name: 'joindomain'
        location: location
        properties: {
          publisher: 'Microsoft.Compute'
          type: 'JsonADDomainExtension'
          typeHandlerVersion: '1.3'
          autoUpgradeMinorVersion: true
          settings: {
            name: 'ottouk.com'
            ouPath: 'OU=Dev,OU=Financier,OU=Servers - Azure,DC=ottouk,DC=com'
            user: 'ottouk.com\\${domainJoinUserName}'
            restart: true
            options: 3
          }
          protectedSettings: {
            Password: domainJoinUserPassword
          }
        }
      }

resource customscriptextension 'Microsoft.Compute/virtualMachines/extensions@2022-03-01' = {
        parent: myVirtualMachine
        name: 'deploy'
        location: location
        properties: {
          publisher: 'Microsoft.Compute'
          type: 'CustomScriptExtension'
          typeHandlerVersion: '1.10'
          autoUpgradeMinorVersion: true
          settings: {
            fileUris: [
            'https://raw.githubusercontent.com/stevericks/Scripts/main/DeployScript.ps1'
            'https://raw.githubusercontent.com/stevericks/Scripts/main/InitializeDataDisk.ps1'
            ]
            commandToExecute: 'powershell -ExecutionPolicy Bypass -File DeployScript.ps1'
          }
        }
      }

output myVmName string = myVirtualMachine.name
