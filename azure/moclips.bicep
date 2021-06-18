@minLength(3)
@maxLength(8)
param projectName string = 'moclips'

@allowed([
  'dev'
  'qa'
  'stg'
  'prod'
])
param projectEnvironment string = 'qa'

param location string = resourceGroup().location
param iotHubSkuName string = 'S1'
param iotHubSkuCapacity int = 1

param provisioningServicesSkuName string = 'S1'
param provisioningServicesSkuCapacity int = 1

var iotHubName = '${projectName}-iothub-${projectEnvironment}'
var iotHubConsumerGroupName = 'adum'
var provisioningServicesName = '${toLower(projectName)}${toLower(projectEnvironment)}${toLower(uniqueString(resourceGroup().id))}'

var aduName = '${projectName}-adu-${projectEnvironment}'
var aduInstanceName = '${projectName}-adui-${projectEnvironment}'


var storageAccountName = '${toLower(projectName)}${toLower(projectEnvironment)}${toLower(uniqueString(resourceGroup().id))}'
var storageEndpoint = '${projectName}StorageEndpoint'
var storageContainerUpdatesName = 'updates'
var storageContainerEventsName = 'events'

resource storageAccountResource 'Microsoft.Storage/storageAccounts@2021-04-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: 'Standard_LRS'
    tier: 'Standard'
  }
  kind: 'StorageV2'
}

resource storageAccountBlobResource 'Microsoft.Storage/storageAccounts/blobServices@2021-04-01' = {
  parent: storageAccountResource
  name: 'default'
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

resource storageAccountBlobContainerResource 'Microsoft.Storage/storageAccounts/blobServices/containers@2021-04-01' = {
  parent: storageAccountBlobResource
  name: 'updates'
  properties: {
    publicAccess: 'None'
  }
  dependsOn: [
    storageAccountResource
  ]
}

resource iotHubResource 'Microsoft.Devices/IotHubs@2020-08-01' = {
  name: iotHubName
  location: location
  tags: {
    '!iot-device-group-names': '["${projectName} Dev Kits"]'
  }
  sku: {
    name: iotHubSkuName
    capacity: iotHubSkuCapacity
  }
  properties: {
    authorizationPolicies: [
      {
        keyName: 'iotHubOwner'
        rights: 'RegistryWrite, ServiceConnect, DeviceConnect'
      }
      {
        keyName: 'service'
        rights: 'ServiceConnect'
      }
      {
        keyName: 'device'
        rights: 'DeviceConnect'
      }
      {
        keyName: 'registryRead'
        rights: 'RegistryRead'
      }
      {
        keyName: 'registryReadWrite'
        rights: 'RegistryWrite'
      }
      {
        keyName: 'deviceUpdateService'
        rights: 'RegistryRead, ServiceConnect, DeviceConnect'
      }
    ]
    cloudToDevice: {
      maxDeliveryCount: 10
      defaultTtlAsIso8601: 'PT1H'
      feedback: {
        lockDurationAsIso8601: 'PT1M'
        ttlAsIso8601: 'PT1H'
        maxDeliveryCount: 10
      }
    }
    enableFileUploadNotifications: false
    features: 'None'
    ipFilterRules: []
    messagingEndpoints: {
      fileNotifications: {
        lockDurationAsIso8601: 'PT1M'
        ttlAsIso8601: 'PT1H'
        maxDeliveryCount: 10
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
          name: 'DeviceUpdate.DeviceTwinChanges'
          source: 'TwinChangeEvents'
          condition: '(opType = "updateTwin" OR opType = "replaceTwin") AND IS_DEFINED($body.tags.ADUGroup)'
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
          name: 'DeviceUpdate.DeviceLifecyle'
          source: 'DeviceLifecycleEvents'
          condition: 'opType = "deleteDeviceIdentity" OR opType = "deleteModuleIdentity"'
          endpointNames: [
            'events'
          ]
          isEnabled: true
        }
  /*
        {
          name: 'DeviceUpdate.Telemetry'
          source: 'DeviceMessages'
          condition: '$iothub-interface-id = "urn:azureiot:ModelDiscovery:ModelInformation:1"'
          endpointNames: [
            'events'
          ]
          isEnabled: true
        }
  */   
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

/*
    storageEndpoints: {
      '$default': {
        sasTtlAsIso8601: 'PT1H'
        connectionString: ''
        containerName: ''
      }
    }
*/
  }
}

resource iotHubEventHubEndpointConsumerGroupResource 'Microsoft.Devices/IotHubs/eventHubEndpoints/ConsumerGroups@2020-08-01' = {
  name: '${iotHubName}/events/${iotHubConsumerGroupName}'
  properties: {
    name: iotHubConsumerGroupName
  }
  dependsOn: [
    iotHubResource
  ]
}


resource aduAccountsResource 'Microsoft.DeviceUpdate/accounts@2020-03-01-preview' = {
  name: aduName
  location: location
  properties: {}
}

resource aduAccountsInstanceResource 'Microsoft.DeviceUpdate/accounts/instances@2020-03-01-preview' = {
  parent: aduAccountsResource
  name: aduInstanceName
  location: location
  properties: {
    iotHubs: [
      {
        resourceId: iotHubResource.id
        ioTHubConnectionString:'HostName=${iotHubResource.properties.hostName};SharedAccessKeyName=${listKeys(iotHubResource.id, iotHubResource.apiVersion).value[0].keyName};SharedAccessKey=${listKeys(iotHubResource.id, iotHubResource.apiVersion).value[0].primaryKey}'
        eventHubConnectionString:'Endpoint=${iotHubResource.properties.eventHubEndpoints.events.endpoint};SharedAccessKeyName=${listKeys(iotHubResource.id, iotHubResource.apiVersion).value[0].keyName};SharedAccessKey=${listKeys(iotHubResource.id, iotHubResource.apiVersion).value[0].primaryKey};EntityPath=${iotHubResource.properties.eventHubEndpoints.events.path}'
      }
    ]
  }
  dependsOn: [
    iotHubResource
    aduAccountsResource
  ]
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
        connectionString:'HostName=${iotHubResource.properties.hostName};SharedAccessKeyName=${listKeys(iotHubResource.id, iotHubResource.apiVersion).value[0].keyName};SharedAccessKey=${listKeys(iotHubResource.id, iotHubResource.apiVersion).value[0].primaryKey}'
        location: location
      }
    ]
    allocationPolicy: 'Hashed'
  }
}

output stgAccount string = storageAccountName
output stgEndpoint string = storageEndpoint
output stgContainerUpdatesName string = storageContainerUpdatesName 
output stgContainerEventsName string = storageContainerEventsName 
