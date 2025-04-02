REGION="westus"
RESOURCE_GROUP_NAME="mi300x"
PUBLIC_SSH_PATH="./pub_ssh_key"
CLOUD_INIT_FILE_PATH="./cloud-init.yaml"


az group create --location $REGION -n $RESOURCE_GROUP_NAME
az vm create --name mi300x --resource-group $RESOURCE_GROUP_NAME --location $REGION --image microsoft-dsvm:ubuntu-hpc:2204-rocm:22.04.2025030701 --size Standard_ND96isr_MI300X_v5 --security-type Standard --os-disk-size-gb 256 --os-disk-delete-option Delete --admin-username azureadmin --ssh-key-values $PUBLIC_SSH_PATH --custom-data $CLOUD_INIT_FILE_PATH
