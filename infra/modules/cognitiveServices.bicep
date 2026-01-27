@description('Name of the Azure OpenAI resource')
param openAIName string

@description('Location for the Azure OpenAI resource')
param location string = resourceGroup().location

@description('SKU for Azure OpenAI resource')
@allowed([
  'S0'
])
param sku string = 'S0'

@description('Name of the model to deploy')
param modelName string

@description('Version of the model')
param modelVersion string = '2024-08-06'

@description('Deployment type for Azure OpenAI')
@allowed([
  'GlobalStandard'
  'Provisioned'
])
param deploymentType string = 'GlobalStandard'

@description('Name for the deployment')
param deploymentName string = '${modelName}-deployment'

@description('Capacity for the deployment (only used for Provisioned deployments)')
param capacity int = 100

@description('Tags to apply to the resource')
param tags object = {}

// Create Azure OpenAI resource
resource openAI 'Microsoft.CognitiveServices/accounts@2023-05-01' = {
  name: openAIName
  location: location
  sku: {
    name: sku
  }
  kind: 'OpenAI'
  properties: {
    customSubDomainName: openAIName
    publicNetworkAccess: 'Enabled'
    networkAcls: {
      defaultAction: 'Allow'
    }
  }
  tags: tags
}

// Create deployment with the specified type
resource deployment 'Microsoft.CognitiveServices/accounts/deployments@2023-05-01' = {
  parent: openAI
  name: deploymentName
  properties: {
    model: {
      format: 'OpenAI'
      name: modelName
      version: modelVersion
    }
    versionUpgradeOption: 'OnceNewDefaultVersionAvailable'
    raiPolicyName: 'Microsoft.Default'
  }
  sku: deploymentType == 'Provisioned' ? {
    name: 'ProvisionedManaged'
    capacity: capacity
  } : {
    name: 'Standard'
  }
}

@description('The resource ID of the Azure OpenAI account')
output openAIId string = openAI.id

@description('The name of the Azure OpenAI account')
output openAIName string = openAI.name

@description('The endpoint of the Azure OpenAI account')
output openAIEndpoint string = openAI.properties.endpoint

@description('The name of the deployment')
output deploymentName string = deployment.name
