# Project Moclips
IoT Experimentation with Project Santa Cruz
A repository for documenting my good practices in getting up and running with Microsoft's [Project Santa Cruz](https://github.com/microsoft/project-santa-cruz)

## Setting Up The Azure Environment
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

Press this button to deploy the people counting application to either the Azure public cloud or your Santa Cruz AI device:

[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fmikelor%2Fmoclips%2Fmain%2Fazure%2Fmoclips.json)

At the moment this creates an Azure IoTHub as well as the Device Provisioning Service

## Links
  * [Santa Cruz AI App](https://github.com/george-moore/Santa-Cruz-AI-App)
