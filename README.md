# Project Moclips
IoT Experimentation with Project Santa Cruz
A repository for documenting my good practices in getting up and running with Microsoft's [Project Santa Cruz](https://github.com/microsoft/project-santa-cruz)

At the moment, this repository contains an Azure Bicep file and generated ARM Template created via
```
bicep build moclips.bicep
```

## Setting Up The Azure Environment
### Via the Command Line
If using WSL and the AZ CLI, simply clone this repository and utilize the azure/deployMoclips.sh script to create the necessary infrastructure for the Santa Cruz development environment

```
cd modclips/azure
./deployMoclips.sh <subscriptionName> <projectName> <projectEnvironment>
```
Where
  * **subscriptionName** is the name of your Azure Subscription
  * **projectName** is the name of your project
  * **environmentName** is one of 3 values dev, qa, prod

The following example will create a "my-cruze-dev-grp" resource group in the YourSubscription Azure Subscription with two resources
  1. my-cruz-iothub-dev
  2. my-cruz-provsvcs-dev

```
cd moclips/azure
./deployMoclips.sh YourSubscription my-cruz dev
```

### Via Azure Deploy
If you'd rather use the Azure Deploy script, simply press Deploy to Azure button below.

[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fmikelor%2Fmoclips%2Fmain%2Fazure%2Fmoclips.json)

At the moment this creates an Azure IoTHub as well as the Device Provisioning Service

### Next Steps
After creating the Azure Environment, you can start the Project Santa Cruz Out of the Box Experience ([OOBE Walkthrough](https://github.com/microsoft/Project-Santa-Cruz-Preview/blob/main/user-guides/getting_started/oobe.md))

## Links
  * [Santa Cruz AI App](https://github.com/george-moore/Santa-Cruz-AI-App)
