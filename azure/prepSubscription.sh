# During preview we need to ensure subscription has approprate providers registered
# https://github.com/microsoft/Project-Santa-Cruz-Preview/blob/main/user-guides/getting_started/azure-subscription-onboarding.md
# Even though Microsoft.DeviceUpdate is not listed, we're adding it, because I had to do this in an earlier subscription
az account set -s $1
az provider register --namespace Microsoft.Devices
az provider register --namespace Microsoft.DeviceUpdate
