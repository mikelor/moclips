param projectName string {
  default: 'moclips'
  minLength: 1
  maxLength: 11
}

param projectEnvironment string {
  default: 'qa'
}

var unique = uniqueString(resourceGroup().id)

param location string = resourceGroup().location
param iotHubSkuName string = 'S1'
param iotHubSkuCapacity int = 1
param iotHubD2CPartitions int = 4

param provisioningServicesSkuName string = 'S1'
param provisioningServicesSkuCapacity int = 1

var iotHubName = '${projectName}-iothub-${projectEnvironment}'
var provisioningServicesName = '${toLower(projectName)}${toLower(projectEnvironment)}${toLower(uniqueString(resourceGroup().id))}'
var deviceUpdatesName = '${projectName}'


var storageAccountName = '${toLower(projectName)}${toLower(projectEnvironment)}${unique}'
var storageEndpoint = '${projectName}StorageEndpoint'
var storageContainerUpdatesName = 'updates'
var storageContainerEventsName = 'events'


resource iotHubResource 'Microsoft.Devices/IotHubs@2020-08-01' = {
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
        eventHubs: []
        serviceBusQueues: []
        serviceBusTopics: []
        storageContainers: []
      }
      routes: [
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
          name: 'DeviceUpdate.DeviceLifecyle'
          source: 'DeviceLifecycleEvents'
          condition: 'opType = "deleteDeviceIdentity"'
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
          condition: '(opType = "updateTwin" OR opType = "replaceTwin")'
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
        connectionString: ''
        containerName: ''
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
  location: location
  sku: {
    name: provisioningServicesSkuName
    capacity: provisioningServicesSkuCapacity
  }
  properties: {
    iotHubs: [
      {
        applyAllocationPolicy: true
        allocationWeight: 1
        connectionString:'HostName=${projectName}-iothub-${projectEnvironment}.azure-devices.net;SharedAccessKeyName=${listKeys(iotHubResource.id, iotHubResource.apiVersion).value[0].keyName};SharedAccessKey=${listKeys(iotHubResource.id, iotHubResource.apiVersion).value[0].primaryKey}'
        location: location
      }
    ]
    allocationPolicy: 'Hashed'
  }
}

resource deviceUdatesResource 'Microsoft.DeviceUpdate/accounts@2020-03-01-preview' = {
  name: deviceUpdatesName
  location: location
  properties: {}
}
