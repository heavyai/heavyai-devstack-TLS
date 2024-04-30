# !/bin/bash
#  This script simply configurs Nvidia drivers in a typical Linux environment.  


install_nvidia_drivers(){

sudo apt install linux-headers-$(uname -r) 
sudo apt install pciutils 
sudo apt install libvulkan1

wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2204/x86_64/cuda-keyring_1.1-1_all.deb
sudo dpkg -i cuda-keyring_1.1-1_all.deb
sudo apt-get update
sudo apt-get -y install cuda-toolkit-12-4

}

nvidia_docker_runtime(){
curl --silent --location https://nvidia.github.io/nvidia-container-runtime/gpgkey | \
sudo apt-key add -
distribution=$(. /etc/os-release;echo $ID$VERSION_ID)
curl --silent --location https://nvidia.github.io/nvidia-container-runtime/$distribution/nvidia-container-runtime.list | \
  sudo tee /etc/apt/sources.list.d/nvidia-container-runtime.list
sudo apt-get update
sudo apt-get install -y nvidia-container-runtime
sudo systemctl restart docker
}

install_nvidia_drivers
nvidia_docker_runtime

