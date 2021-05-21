# Project Moclips
IoT Experimentation with Project Santa Cruz

A repository for documenting my good practices in getting up and running with Microsoft's [Azure Percept Private Preview](https://github.com/microsoft/Azure-Percept-Private-Preview)

At the moment, this repository contains an [Azure Bicep](https://github.com/Azure/bicep) file and generated ARM Template created via the bicep build command.
```
$ bicep build moclips.bicep
```
You do not need to install bicep to utilize this repo.
You can use the generated ARM template to setup the Azure Environment needed for the Project Santa Cruz DevKit.

## Setting Up The Azure Environment
Currently there are two ways to setup your Azure Environment:
  1. Via the WSL (Windows Subsystem for Linux) Command Line
  2. Via the Deploy to Azure Button

### Via the Command Line
If using WSL and the AZ CLI, simply clone this repository and utilize the azure/deployMoclips.sh script to create the necessary infrastructure for the Santa Cruz development environment

```
$ cd moclips/azure
$ ./deployMoclips.sh <subscriptionName> <projectName> <projectEnvironment>
```
Where
  * **subscriptionName** is the name of your Azure Subscription
  * **projectName** is the name of your project
  * **environmentName** is one of 3 values dev, qa, prod

The following example will create a "my-cruze-dev-grp" resource group in the YourSubscription Azure Subscription with two resources
  1. my-cruz-iothub-dev
  2. my-cruz-provsvcs-dev

```
$ cd moclips/azure
$ ./deployMoclips.sh YourSubscription my-cruz dev
```

### Via Azure Deploy
If you'd rather use the Azure Deploy script, simply press Deploy to Azure button below.

[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fmikelor%2Fmoclips%2Fmain%2Fazure%2Fmoclips.json)

At the moment this creates an Azure IoTHub as well as the Device Provisioning Service

### Next Steps
After creating the Azure Environment, you can start the Azure Percept Out of the Box Experience ([OOBE Walkthrough](https://docs.microsoft.com/en-us/azure/azure-percept/quickstart-percept-dk-unboxing))

## Links
Azure resources that may be helpful in building your Percept based solution
  * [Azure Live Analytics](https://techcommunity.microsoft.com/t5/internet-of-things/new-capabilities-from-azure-live-video-analytics/ba-p/2215642)
  * [Azure IoT Central](https://apps.azureiotcentral.com/)

Here are some links to some interesting projects that that people are working on with Azure Percept
  * [Santa Cruz AI App](https://github.com/george-moore/Santa-Cruz-AI-App)
  * [Package Delivery Monitoring](https://techcommunity.microsoft.com/t5/internet-of-things/set-up-your-own-end-to-end-package-delivery-monitoring-ai/ba-p/2323165)
  * [Percept Mobile - Obstacle Avoidance Lego Car](https://techcommunity.microsoft.com/t5/internet-of-things/perceptmobile-azure-percept-obstacle-avoidance-lego-car/ba-p/2352666)

#### Why Moclips?
I needed a project name, and since Santa Cruz is a city on the California coast, I chose wonderful Moclips, WA. Definitely not Santa Cruz, but if you need some good Clam Chowder, stop by the Ocean Crest resort.
