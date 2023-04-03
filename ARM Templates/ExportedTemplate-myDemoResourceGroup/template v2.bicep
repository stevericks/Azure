param vmName string
param location string
param vmSize string
param AdminUsername string

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
          id: resourceId('Microsoft.Compute/disks/', '${vmName}_OsDisk')
        }
        deleteOption: 'Detach'
      }
      dataDisks: [
        {
          lun: 0
          name: 'DataDisk'
          createOption: 'Attach'
          caching: 'None'
          writeAcceleratorEnabled: false
          managedDisk: {
            id: resourceId('Microsoft.Compute/disks/', '${vmName}_DataDisk')
          }
          deleteOption: 'Detach'
          toBeDetached: false
        }
      ]
    }
    osProfile: {
      computerName: vmName
      adminUsername: AdminUsername
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
      requireGuestProvisionSignal: true
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: resourceId('Microsoft.Compute/network/', '${vmName}_nic')
        }
      ]
    }
  }
}
