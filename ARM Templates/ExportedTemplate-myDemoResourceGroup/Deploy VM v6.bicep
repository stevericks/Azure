param vmName string
param location string
param vmSize string
param AdminUsername string
@secure()
param AdminPassword string

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
            id: resourceId('Microsoft.Network/virtualNetworks/subnets', 'MyDemoVnet', 'myDemoSubnet')
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
        sku: '2019-Datacenter'
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

output myVmName string = myVirtualMachine.name
