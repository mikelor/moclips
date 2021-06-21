# Project Moclips
A repository for documenting *my* good practices for setting up an IoT infrastructure environment that works with [Azure Percept Device Kit](https://docs.microsoft.com/en-us/azure/azure-percept/overview-azure-percept-dk) and other IoT Edge devices. If you are starting a new IoT Edge project, give this implementation a try.

The following environment diagram for an overview of the resources created. **Note:** *Currently the Device Provisioing Service is commented out in the moclips template. This will be added back in a future iteration.*

![Moclips Environment Diagram](https://github.com/mikelor/moclips/blob/main/doc/moclipsenvironment.png).

| Azure Resource | Resource Name | Description |
| -------------- | :------------ | ----------- |
| [IoT Hub ](https://docs.microsoft.com/en-us/azure/iot-hub/about-iot-hub) | &lt;prj&gt;-iothub-&lt;env&gt; | A central message hub for communications in both directions between your IoT application and IoT Edge devices (including Azure Percept). |
| [Storage Account](https://docs.microsoft.com/en-us/azure/storage/blobs/storage-blobs-introduction) | &lt;prj&gt;&lt;env&gt;xxx  | Provides storage resources for the moclips infrastructure environment. Currently used to store IoT Edge Device Update Images to be used with the Device Update Service. |
| [Device Provisioning Service for IotHub](https://docs.microsoft.com/en-us/azure/iot-dps/about-iot-dps) | ~~&lt;prj&gt;-dps-&lt;env&gt;~~  | Allows for zero-touch device provisiong of Azure Percept and other IoT Edge devices **Note:** *This component is commented out in the current iteration as it has yet to be validated* |
| [Device Update for Iot Hub](https://docs.microsoft.com/en-us/azure/iot-hub-device-update/understand-device-update) | &lt;prj&gt;-adu-&lt;env&gt;  | Updates IoT Edge devices attached to IoT Hub using Over The Air (OTA) capability. There is currently a limit of one Device Update account per Subscription. Multiple Device Update Instances (ADUI) can be created to serve multiple IoT Hub instances. In the future we may want to break the Device Update Account from this Resource Group. |

## Getting Started
This repository contains an [Azure Bicep](https://github.com/Azure/bicep) file, [moclips.bicep](https://github.com/mikelor/moclips/blob/main/azure/moclips.bicep) and generated ARM Template, [moclips.json](https://github.com/mikelor/moclips/blob/main/azure/moclips.json). This repository uses the [Azure CLI method of running bicep](https://github.com/Azure/bicep/blob/main/docs/installing.md#install-and-manage-via-azure-cli-easiest).
You do not need to install bicep to utilize this repo, the generated ARM template is all you need to setup the Azure Environment for Azure Percept.

## Setting Up The Azure Environment
Currently there are two ways to setup your Azure Environment:
  1. Using the Azure Command Line Interface
  2. Using the Deploy to Azure Button

### Using the Azure CLI
If using WSL and the AZ CLI, simply clone this repository and utilize the  [azure/deployMoclips.sh](https://github.com/mikelor/moclips/blob/main/azure/deployMoclips.sh) script to create the necessary infrastructure to support Azure Percept (and other IoT Edge devices)

```
$ git clone https://github.com/mikelor/moclips.git
$ cd moclips/azure
$ ./deployMoclips.sh <subscriptionName> <projectName> <projectEnvironment>
```
Where
  * **&lt;subscriptionName&gt;** is the name of your Azure Subscription
  * **&lt;projectName&gt;** is the prefex name of your project
  * **&lt;environmentName&gt;** is one of 3 values dev, qa, prod

The following example will create a "cruz-dev-grp" resource group in the YourSubscription Azure Subscription with the following high-level resources

```
$ cd moclips/azure
$ ./azure/deployMoclips.sh YourSubscription my-cruz dev
```

### Using Azure Deploy
If you'd rather use the Azure Deploy script, simply press **Deploy to Azure** button below.

[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fmikelor%2Fmoclips%2Fmain%2Fazure%2Fmoclips.json)


### Next Steps
After creating the Azure Environment, you can start the Azure Percept Out of the Box Experience ([OOBE Walkthrough](https://docs.microsoft.com/en-us/azure/azure-percept/quickstart-percept-dk-unboxing))

I'll be leveraging the Moclips Azure Environment for all of my future forays into Azure hosted IoT solutions. Please check out my first project:
1. [Dark Sense](https://github.com/mikelor/darksense). Using Azure Percept Studio and the Azure Percept Device Kit to identify timeline events in the turn of commercial aircraft.

## Links
Azure resources that may be helpful in building your Percept based solution
  * [Azure Live Analytics](https://techcommunity.microsoft.com/t5/internet-of-things/new-capabilities-from-azure-live-video-analytics/ba-p/2215642)
  * [Azure IoT Central](https://apps.azureiotcentral.com/)

Here are some links to some interesting projects that that people are working on with Azure Percept
  * [Santa Cruz AI App](https://github.com/george-moore/Santa-Cruz-AI-App)
  * [Package Delivery Monitoring](https://techcommunity.microsoft.com/t5/internet-of-things/set-up-your-own-end-to-end-package-delivery-monitoring-ai/ba-p/2323165)
  * [Percept Mobile - Obstacle Avoidance Lego Car](https://techcommunity.microsoft.com/t5/internet-of-things/perceptmobile-azure-percept-obstacle-avoidance-lego-car/ba-p/2352666)

## Future Reading
This setion contains links to documentation that may be helpful in implementing future features.
  * [What is the IoT Hub Device Provisioning Service](https://docs.microsoft.com/en-us/azure/iot-dps/about-iot-dps) - This will be useful when we implement the Device Provisioning Service
  * [Azure Percept Security Overview](https://docs.microsoft.com/en-us/azure/azure-percept/overview-percept-security) - This will be useful when we implement the Device Provisioing Service

## Contributing
If you are interested in contributing or providing feedback, please open an issue and submit a pull request.

## Why Moclips?
Before there was Azure Percept, there was [Project Santa Cruz](https://www.microsoft.com/en-us/us-partner-blog/events/1-14-ai-with-the-santa-cruz-dev-kit/), an early iteration and private preview of the Azure Percept Device Kit. I needed a project name, and since Santa Cruz is a city on the California coast, I chose wonderful [Moclips, WA](https://en.wikipedia.org/wiki/Moclips,_Washington). Definitely not Santa Cruz, but if you need some good Clam Chowder, stop by the Ocean Crest resort.
