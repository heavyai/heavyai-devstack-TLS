# !/bin/bash
#  This script simply configurs Nvidia drivers in a typical Linux environment.  


nvidia_docker_runtime(){
curl --silent --location https://nvidia.github.io/nvidia-container-runtime/gpgkey | \
sudo apt-key add -
distribution=$(. /etc/os-release;echo $ID$VERSION_ID)
curl --silent --location https://nvidia.github.io/nvidia-container-runtime/$distribution/nvidia-container-runtime.list | \
  sudo tee /etc/apt/sources.list.d/nvidia-container-runtime.list
sudo apt-get update
sudo apt-get install -y nvidia-container-runtime
sudo nvidia-ctk runtime configure --runtime=docker

sudo systemctl restart docker
sudo docker run --rm --gpus all ubuntu nvidia-smi
}


nvidia_docker_runtime

