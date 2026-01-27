#!/bin/bash
# Azure OpenAI Deployment Script
# This script simplifies the deployment of Azure OpenAI resources

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Function to display usage
usage() {
    cat << EOF
Usage: $0 [OPTIONS]

Deploy Azure OpenAI resources using Bicep templates.

OPTIONS:
    -h, --help              Show this help message
    -t, --type              Deployment type: globalstandard or provisioned (default: globalstandard)
    -r, --resource-group    Name of the resource group
    -n, --name              Name of the Azure OpenAI resource
    -m, --model             Model name (e.g., gpt-4, gpt-35-turbo)
    -l, --location          Azure region (default: eastus)
    -v, --validate          Validate template without deploying
    -w, --what-if           Preview changes without deploying

EXAMPLES:
    # Deploy with GlobalStandard (default)
    $0 --resource-group rg-openai --name openai-demo --model gpt-4

    # Deploy with Provisioned
    $0 --type provisioned --resource-group rg-openai --name openai-prod --model gpt-4

    # Validate template
    $0 --validate --resource-group rg-openai --name openai-demo --model gpt-4

    # Preview changes
    $0 --what-if --resource-group rg-openai --name openai-demo --model gpt-4
EOF
    exit 0
}

# Default values
DEPLOYMENT_TYPE="globalstandard"
LOCATION="eastus"
VALIDATE_ONLY=false
WHAT_IF=false

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            usage
            ;;
        -t|--type)
            DEPLOYMENT_TYPE="$2"
            shift 2
            ;;
        -r|--resource-group)
            RESOURCE_GROUP="$2"
            shift 2
            ;;
        -n|--name)
            OPENAI_NAME="$2"
            shift 2
            ;;
        -m|--model)
            MODEL_NAME="$2"
            shift 2
            ;;
        -l|--location)
            LOCATION="$2"
            shift 2
            ;;
        -v|--validate)
            VALIDATE_ONLY=true
            shift
            ;;
        -w|--what-if)
            WHAT_IF=true
            shift
            ;;
        *)
            print_error "Unknown option: $1"
            usage
            ;;
    esac
done

# Validate required parameters
if [ -z "$RESOURCE_GROUP" ] || [ -z "$OPENAI_NAME" ] || [ -z "$MODEL_NAME" ]; then
    print_error "Missing required parameters"
    usage
fi

# Validate deployment type
if [[ "$DEPLOYMENT_TYPE" != "globalstandard" && "$DEPLOYMENT_TYPE" != "provisioned" ]]; then
    print_error "Invalid deployment type: $DEPLOYMENT_TYPE. Must be 'globalstandard' or 'provisioned'"
    exit 1
fi

# Convert to proper case for Bicep parameter
if [ "$DEPLOYMENT_TYPE" == "globalstandard" ]; then
    BICEP_DEPLOYMENT_TYPE="GlobalStandard"
else
    BICEP_DEPLOYMENT_TYPE="Provisioned"
fi

print_info "Configuration:"
print_info "  Resource Group: $RESOURCE_GROUP"
print_info "  OpenAI Name: $OPENAI_NAME"
print_info "  Model: $MODEL_NAME"
print_info "  Location: $LOCATION"
print_info "  Deployment Type: $BICEP_DEPLOYMENT_TYPE"

# Check if Azure CLI is installed
if ! command -v az &> /dev/null; then
    print_error "Azure CLI is not installed. Please install it first."
    exit 1
fi

# Check if logged in to Azure
if ! az account show &> /dev/null; then
    print_error "Not logged in to Azure. Please run 'az login' first."
    exit 1
fi

# Get the directory where the script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Validate template
if [ "$VALIDATE_ONLY" = true ]; then
    print_info "Validating template..."
    az deployment sub validate \
        --location "$LOCATION" \
        --template-file "$SCRIPT_DIR/main.bicep" \
        --parameters \
            resourceGroupName="$RESOURCE_GROUP" \
            openAIName="$OPENAI_NAME" \
            modelName="$MODEL_NAME" \
            location="$LOCATION" \
            deploymentType="$BICEP_DEPLOYMENT_TYPE"
    print_info "Template validation completed successfully!"
    exit 0
fi

# What-if analysis
if [ "$WHAT_IF" = true ]; then
    print_info "Running what-if analysis..."
    az deployment sub what-if \
        --location "$LOCATION" \
        --template-file "$SCRIPT_DIR/main.bicep" \
        --parameters \
            resourceGroupName="$RESOURCE_GROUP" \
            openAIName="$OPENAI_NAME" \
            modelName="$MODEL_NAME" \
            location="$LOCATION" \
            deploymentType="$BICEP_DEPLOYMENT_TYPE"
    exit 0
fi

# Deploy
print_info "Starting deployment..."
DEPLOYMENT_NAME="openai-deployment-$(date +%s)"

az deployment sub create \
    --name "$DEPLOYMENT_NAME" \
    --location "$LOCATION" \
    --template-file "$SCRIPT_DIR/main.bicep" \
    --parameters \
        resourceGroupName="$RESOURCE_GROUP" \
        openAIName="$OPENAI_NAME" \
        modelName="$MODEL_NAME" \
        location="$LOCATION" \
        deploymentType="$BICEP_DEPLOYMENT_TYPE"

if [ $? -eq 0 ]; then
    print_info "Deployment completed successfully!"
    print_info "Retrieving outputs..."
    
    # Get deployment outputs
    OUTPUTS=$(az deployment sub show --name "$DEPLOYMENT_NAME" --query properties.outputs -o json)
    
    if [ ! -z "$OUTPUTS" ]; then
        print_info "Deployment Outputs:"
        echo "$OUTPUTS" | jq '.'
    fi
else
    print_error "Deployment failed!"
    exit 1
fi
