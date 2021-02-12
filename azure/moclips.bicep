param projectName string {
  default: 'moclips'
  minLength: 1
  maxLength: 11
}

param projectEnvironment string {
  default: 'dev'
}

var unique = uniqueString(resourceGroup().id)

param location string = resourceGroup().location
param iotHubSkuName string = 'S1'
param iotHubSkuCapacity int = 1
param iotHubD2CPartitions int = 4


var iotHubName = '${projectName}-iothub-${projectEnvironment}'

var storageAccountName = '${toLower(projectName)}${toLower(projectEnvironment)}${unique}'
var storageEndpoint = '${projectName}StorageEndpoint'
var storageContainerUpdatesName = 'updates'
var storageContainerEventsName = 'events'

var provisioningServicesName = '${projectName}-prvsvcs-${projectEnvironment}'

resource storageAccountResource 'Microsoft.Storage/storageAccounts@2020-08-01-preview' = {
  name: storageAccountName
  location: location
  sku: {
    name: 'Standard_LRS'
    tier: 'Standard'
  }
  kind: 'StorageV2'
  properties: {
    isHnsEnabled: false
    networkAcls: {
      bypass: 'AzureServices'
      virtualNetworkRules: []
      ipRules: []
      defaultAction: 'Allow'
    }
    supportsHttpsTrafficOnly: true
    encryption: {
      services: {
        file: {
          keyType: 'Account'
          enabled: true
        }
        blob: {
          keyType: 'Account'
          enabled: true
        }
      }
      keySource: 'Microsoft.Storage'
    }
    accessTier: 'Hot'
  }
}

resource blobServicesResource 'Microsoft.Storage/storageAccounts/blobServices@2020-08-01-preview' = {
  name: '${storageAccountResource.name}/default'
  properties: {
    cors: {
      corsRules: [
        {
          allowedOrigins: [
            'https://iothub.hosting.portal.azure.net'
          ]
          allowedMethods: [
            'DELETE'
            'GET'
            'HEAD'
            'MERGE'
            'POST'
            'OPTIONS'
            'PUT'
            'PATCH'
          ]
          maxAgeInSeconds: 3000
          exposedHeaders: [
            '*'
          ]
          allowedHeaders: [
            '*'
          ]
        }
      ]
    }
    deleteRetentionPolicy: {
      enabled: false
    }
  }
}

resource storageAccountContainerResource 'Microsoft.Storage/storageAccounts/blobServices/containers@2020-08-01-preview' = {
  name: '${storageAccountResource.name}/default/${storageContainerUpdatesName}'
  properties: {
    defaultEncryptionScope: '$account-encryption-key'
    denyEncryptionScopeOverride: false
    publicAccess: 'None'
  }
  dependsOn: [
    storageAccountResource
  ]
}


resource iotHubResource 'Microsoft.Devices/IotHubs@2020-07-10-preview' = {
  name: iotHubName
  location: location
  tags: {
    '!iot-device-group-names': '["Santa Cruz Dev Kits"]'
  }
  sku: {
    name: iotHubSkuName
    capacity: iotHubSkuCapacity
  }
  properties: {
    ipFilterRules: []
    eventHubEndpoints: {
      events: {
        retentionTimeInDays: 1
        partitionCount: iotHubD2CPartitions
      }
    }
    routing: {
      endpoints: {
        storageContainers: [
          {
            // really need a listConnectionString() function
            connectionString: 'DefaultEndpointsProtocol=https;AccountName=${storageAccountName};EndpointSuffix=${environment().suffixes.storage};AccountKey=${listKeys(storageAccountResource.id, storageAccountResource.apiVersion).keys[0].value}'
            containerName: storageContainerEventsName
            fileNameFormat: '{iothub}/{partition}/{YYYY}/{MM}/{DD}/{HH}/{mm}'
            batchFrequencyInSeconds: 100
            maxChunkSizeInBytes: 104857600
            encoding: 'JSON'
            name: storageEndpoint
          }
        ]
      }
      routes: [
        {
          name: 'DigitalTwinChanges'
          source: 'DigitalTwinChangeEvents'
          condition: 'true'
          endpointNames: [
            'events'
          ]
          isEnabled: true
        }
        {
          name: 'DeviceLifeCycle'
          source: 'DeviceLifecycleEvents'
          condition: 'opType = \'deleteDeviceIdentity\''
          endpointNames: [
            'events'
          ]
          isEnabled: true
        }
        {
          name: 'TelemetryModelInformation'
          source: 'DeviceMessages'
          condition: '$iothub-interface-id = "urn:azureiot:ModelDiscovery:ModelInformation:1"'
          endpointNames: [
            'events'
          ]
          isEnabled: true
        }
        {
          name: 'DeviceUpdate.DigitalTwinChanges'
          source: 'DigitalTwinChangeEvents'
          condition: 'true'
          endpointNames: [
            'events'
          ]
          isEnabled: true
        }
        {
          name: 'DeviceUpdate.DeviceLifeCycle'
          source: 'DeviceLifecycleEvents'
          condition: 'opType = \'deleteDeviceIdentity\''
          endpointNames: [
            'events'
          ]
          isEnabled: true
        }
        {
          name: 'DeviceUpdate.Telemetry'
          source: 'DeviceMessages'
          condition: '$iothub-interface-id = "urn:azureiot:ModelDiscovery:ModelInformation:1"'
          endpointNames: [
            'events'
          ]
          isEnabled: true
        }
        {
          name: 'DeviceUpdate.DeviceTwinChanges'
          source: 'TwinChangeEvents'
          condition: '(opType = \'updateTwin\' OR opType = \'replaceTwin\')'
          endpointNames: [
            'events'
          ]
          isEnabled: true
        }
      ]
      fallbackRoute: {
        name: '$fallback'
        source: 'DeviceMessages'
        condition: 'true'
        endpointNames: [
          'events'
        ]
        isEnabled: true
      }
    }
    storageEndpoints: {
      '$default': {
        sasTtlAsIso8601: 'PT1H'
        connectionString: 'DefaultEndpointsProtocol=https;AccountName=${storageAccountName};EndpointSuffix=${environment().suffixes.storage};AccountKey=${listKeys(storageAccountResource.id, storageAccountResource.apiVersion).keys[0].value}'
        containerName: storageContainerEventsName
      }
    }
    messagingEndpoints: {
      fileNotifications: {
        lockDurationAsIso8601: 'PT1M'
        ttlAsIso8601: 'PT1H'
        maxDeliveryCount: 10
      }
    }
    enableFileUploadNotifications: false
    cloudToDevice: {
      maxDeliveryCount: 10
      defaultTtlAsIso8601: 'PT1H'
      feedback: {
        lockDurationAsIso8601: 'PT1M'
        ttlAsIso8601: 'PT1H'
        maxDeliveryCount: 10
      }
    }
    features: 'None'
  }
}

resource provisioningServicesResource 'Microsoft.Devices/provisioningServices@2020-03-01' = {
  name: provisioningServicesName
  location: 'West US'
  sku: {
    name: 'S1'
    capacity: 1
  }
  properties: {
    state: 'Active'
    provisioningState: 'Succeeded'
    iotHubs: [
      {
        applyAllocationPolicy: true
        allocationWeight: 1
        connectionString: 'HostName=${projectName}-iothub-${projectEnvironment}.azure-devices.net;SharedAccessKeyName=${listKeys(iotHubResource.id, iotHubResource.apiVersion).value[0].keyName};SharedAccessKey=${listKeys(iotHubResource.id, iotHubResource.apiVersion).value[0].primaryKey}'
        location: location
      }
    ]
    allocationPolicy: 'Hashed'
  }
}
