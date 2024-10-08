#!/bin/bash
# This script configures Nvidia drivers and sets up the Nvidia container toolkit in a typical Linux environment.

nvidia_docker_toolkit(){
  # Add Nvidia Container Toolkit GPG key
  curl --silent --location https://nvidia.github.io/nvidia-container-toolkit/gpgkey | sudo apt-key add -

  # Add Nvidia Container Toolkit repository
  distribution=$(. /etc/os-release;echo $ID$VERSION_ID)
  curl --silent --location https://nvidia.github.io/nvidia-container-toolkit/$distribution/nvidia-container-toolkit.list | \
    sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list

  # Update package lists and install Nvidia container toolkit
  sudo apt-get update
  sudo apt-get install -y nvidia-container-toolkit

  # Configure Docker to use Nvidia container toolkit by default
  sudo nvidia-ctk runtime configure --runtime=docker --set-as-default

  # Create or update the Docker daemon.json file
  sudo bash -c 'cat > /etc/docker/daemon.json << EOF
{
    "default-runtime": "nvidia",
    "exec-opts": ["native.cgroupdriver=cgroupfs"], 
    "runtimes": {
        "nvidia": {
            "args": [],
            "path": "nvidia-container-runtime"
        }
    }
}
EOF'

  # Restart Docker service to apply changes
  sudo systemctl restart docker

  # Test the Nvidia container toolkit with a Docker container
  sudo docker run --rm --gpus all ubuntu nvidia-smi
}

# Call the function
nvidia_docker_toolkit
