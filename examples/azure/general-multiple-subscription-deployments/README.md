### Deploy to multiple subscriptions

To deploy your resources / use existing resources across multiple subscriptions, you need to specify multiple azurerm providers and use alias on each provider. 

Your account must have permissions on both subscriptions to deploy resources. If not, following error could appear (when you don't have permission to deploy resources in subscription 2):
![alt text](../charts/multiple-subscription.png?raw=true)
