#!/bin/bash

# Create random string
guid=$(cat /dev/urandom | LC_ALL=C tr -dc 'a-zA-Z0-9' | fold -w 10 | head -n 1)
suffix=${guid//[-]/}
suffix=${suffix:0:18}

# Set the necessary variables
RESOURCE_GROUP="rg-mlops-hanna-l${suffix}"
RESOURCE_PROVIDER="Microsoft.MachineLearning"
REGION="swedencentral"
WORKSPACE_NAME="mlw-mlops-hanna-l${suffix}"
COMPUTE_INSTANCE="compute-instance-hanna"
COMPUTE_CLUSTER="aml-cluster-hanna"

# Register the Azure Machine Learning resource provider in the subscription
echo "Register the Machine Learning resource provider:"
az provider register --namespace $RESOURCE_PROVIDER

# Create the resource group and workspace and set to default
echo "Create a resource group and set as default:"
az group create --name $RESOURCE_GROUP --location $REGION
az configure --defaults group=$RESOURCE_GROUP

echo "Create an Azure Machine Learning workspace:"
az ml workspace create --name $WORKSPACE_NAME 
az configure --defaults workspace=$WORKSPACE_NAME 

# # Create compute instance
echo "Creating a compute instance with name: " $COMPUTE_INSTANCE
az ml compute create --name ${COMPUTE_INSTANCE} --size STANDARD_DS11_V2 --type ComputeInstance

# # Create compute cluster
echo "Creating a compute cluster with name: " $COMPUTE_CLUSTER
az ml compute create --name ${COMPUTE_CLUSTER} --size STANDARD_DS11_V2 --max-instances 2 --type AmlCompute 

# Create data asset
echo "Creating a data asset with name: diabetes-dev-folder"
az ml data create --name diabetes-dev-folder --path ./experimentation/data/

# Create production data asset
echo "Creating a production data asset with name: diabetes-prod-folder"
az ml data create --name diabetes-prod-folder --path ./production/data/
