# Create AMD MI300x VM in Azure

This repository contains scripts and configuration files to create an AMD MI300x virtual machine in Azure. The setup includes configuring NVMe storage, Docker, and environment variables for optimal performance.

## Prerequisites

1. **Azure CLI**: Ensure you have the Azure CLI installed and authenticated. You can download it [here](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli).
2. **SSH Key**: Generate an SSH key pair if you don't already have one. Place the public key in the `pub_ssh_key` file.
3. **Azure Subscription**: Ensure you have an active Azure subscription with sufficient quota for the `Standard_ND96isr_MI300X_v5` VM size.
   - To check your quota, run the following Azure CLI command:
     ```sh
     az vm list-usage --location westus --output table |grep MI300X
     ```
   - Look for the "NDv5 Series" quota and ensure it meets the requirements for the `Standard_ND96isr_MI300X_v5` VM size.

## Files in this Repository

- **`cloud-init.yaml`**: Cloud-init configuration file for setting up NVMe storage, Docker, and environment variables.
- **`create_vm.sh`**: Bash script to create the VM in Azure using the Azure CLI.
- **`pub_ssh_key`**: File to store the public SSH key used for VM authentication.
- **`README.md`**: Documentation for the repository.

## Steps to Create the VM

1. Clone this repository:
   ```sh
   git clone <repository-url>
   cd azure-mi300x
   ```

2. Add your public SSH key to the `pub_ssh_key` file:
   ```sh
   echo "your-public-ssh-key" > pub_ssh_key
   ```

3. Run the `create_vm.sh` script:
   ```sh
   chmod u+x create_vm.sh
   ./create_vm.sh
   ```

   This script will:
   - Create a resource group in the `westus` region.
   - Deploy an AMD MI300x VM with the specified configuration.
   - Apply the `cloud-init.yaml` configuration to set up the VM.

## Cloud-Init Configuration

The `cloud-init.yaml` file performs the following tasks:
- Updates the package list.
- Configures NVMe storage as a RAID 0 array and mounts it to `/mnt/resource_nvme`.
- Sets up Docker with a custom data root on the NVMe storage.
- Configures environment variables for Hugging Face cache.

## Verifying the Setup

1. SSH into the VM:
   ```sh
   ssh azureadmin@<vm-ip-address>
   ```

2. Verify NVMe storage:
   ```sh
   df -h | grep /mnt/resource_nvme
   ```

3. Check Docker configuration:
   ```sh
   docker info | grep "Docker Root Dir"
   ```

## Cleanup

To delete the resource group and all associated resources:
```sh
az group delete --name mi300x --yes --no-wait
```

## License

This project is licensed under the MIT License. See the LICENSE file for details.
