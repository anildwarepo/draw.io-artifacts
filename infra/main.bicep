targetScope = 'subscription'

@description('Name of the resource group')
param resourceGroupName string

@description('Location for all resources')
param location string = deployment().location

@description('Name of the Azure OpenAI resource')
param openAIName string

@description('Name of the model to deploy (e.g., gpt-4, gpt-35-turbo, text-embedding-ada-002)')
param modelName string

@description('Version of the model')
param modelVersion string = '2024-08-06'

@description('Deployment type for Azure OpenAI - GlobalStandard for pay-as-you-go, Provisioned for PTU-based')
@allowed([
  'GlobalStandard'
  'Provisioned'
])
param deploymentType string = 'GlobalStandard'

@description('Name for the deployment')
param deploymentName string = '${modelName}-deployment'

@description('Capacity for the deployment (only used for Provisioned deployments, represents PTUs)')
param capacity int = 100

@description('Tags to apply to all resources')
param tags object = {
  Environment: 'Development'
  ManagedBy: 'Bicep'
}

// Create resource group
resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: resourceGroupName
  location: location
  tags: tags
}

// Deploy Azure OpenAI with the specified deployment type
module openAI './modules/cognitiveServices.bicep' = {
  scope: rg
  name: 'openAI-deployment'
  params: {
    openAIName: openAIName
    location: location
    modelName: modelName
    modelVersion: modelVersion
    deploymentType: deploymentType
    deploymentName: deploymentName
    capacity: capacity
    tags: tags
  }
}

@description('The resource ID of the Azure OpenAI account')
output openAIId string = openAI.outputs.openAIId

@description('The name of the Azure OpenAI account')
output openAIName string = openAI.outputs.openAIName

@description('The endpoint of the Azure OpenAI account')
output openAIEndpoint string = openAI.outputs.openAIEndpoint

@description('The name of the deployment')
output deploymentName string = openAI.outputs.deploymentName

@description('The deployment type used')
output deploymentType string = deploymentType
