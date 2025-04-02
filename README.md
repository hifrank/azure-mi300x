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
## Running SG Lang server with DeepSeek R1

```sh
docker pull rocm/sgl-dev:upstream_20250312_v1
docker run \
  --device=/dev/kfd \
  --device=/dev/dri \
  --security-opt seccomp=unconfined \
  --cap-add=SYS_PTRACE \
  --group-add video \
  --privileged \
  --shm-size 32g \
  --ipc=host \
  -p 30000:30000 \
  -v /mnt/resource_nvme:/mnt/resource_nvme \
  -e HF_HOME=/mnt/resource_nvme/hf_cache \
  -e HSA_NO_SCRATCH_RECLAIM=1 \
  -e GPU_FORCE_BLIT_COPY_SIZE=64 \
  -e DEBUG_HIP_BLOCK_SYN=1024 \
  rocm/sgl-dev:upstream_20250312_v1 \
  python3 -m sglang.launch_server --model deepseek-ai/DeepSeek-R1 --tp 8 --trust-remote-code --chunked-prefill-size 131072  --torch-compile-max-bs 256 --host 0.0.0.0 
```
 Once the application outputs “The server is fired up and ready to roll!”, you can begin making queries to the model. 

 ```sh
 curl http://localhost:30000/get_model_info 
{"model_path":"deepseek-ai/DeepSeek-R1","tokenizer_path":"deepseek-ai/DeepSeek-R1","is_generation":true}
```
```sh 
curl http://localhost:30000/generate -H "Content-Type: application/json" -d '{ "text": "Once upon a time,", "sampling_params": { "max_new_tokens": 16, "temperature": 0.6 } }'
 ```
## Cleanup

To delete the resource group and all associated resources:
```sh
az group delete --name mi300x --yes --no-wait
```
## Reference
1. [Running DeepSeek-R1 on a single NDv5 MI300X VM](https://techcommunity.microsoft.com/blog/azurehighperformancecomputingblog/running-deepseek-r1-on-a-single-ndv5-mi300x-vm/4372726)
2. [Supercharge DeepSeek-R1 Inference on AMD Instinct MI300X](https://rocm.blogs.amd.com/artificial-intelligence/DeepSeekR1-Part2/README.html)

## License

This project is licensed under the MIT License. See the LICENSE file for details.
