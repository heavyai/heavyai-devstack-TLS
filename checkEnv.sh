#!/bin/bash

# Define colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

os_packages=("docker.io" "xmlstarlet")
missing_packages=()
UPDATE_DONE=0

echo -e "${BLUE}Checking for required packages...${NC}"
for package in "${os_packages[@]}"; do
    if dpkg -l | grep -q "^ii\s\+$package\s"; then
        echo -e "$package:   [${GREEN}Installed${NC}]"
    else
        echo -e "$package:   [${RED}Not Installed${NC}]"
        missing_packages+=("$package")
    fi
done

installPackage(){
    PACKAGE_NAME=$1
    echo "Would you like to install $PACKAGE_NAME [y/n]"
    read answer

    case $answer in
        [Yy]* )
            echo "Installing $PACKAGE_NAME";
            if [ $UPDATE_DONE -eq 0 ]; then
                echo "Updating APT repository"
                sudo apt-get update
                UPDATE_DONE=1
            fi
            sudo apt-get install -y $PACKAGE_NAME
            ;;
        [Nn]* )
            echo "Skipping $PACKAGE_NAME"
            ;;
        * )
            echo "Invalid choice."
            ;;
    esac
}

for package in "${missing_packages[@]}"; do
    installPackage $package
done

echo -e "${BLUE}Checking NVIDIA GPU and Docker configuration...${NC}"

if command -v nvidia-smi &> /dev/null; then
    echo -e "${GREEN}NVIDIA drivers are installed.${NC}"
    nvidia-smi
else
    echo -e "${RED}NVIDIA drivers are not installed.${NC}"
fi

# Configuring Docker
USER_NAME=$(whoami)

group_exists() {
    getent group docker > /dev/null 2>&1
}

if ! group_exists; then
    echo "The docker group does not exist. Creating docker group..."
    sudo groupadd docker
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}Docker group created successfully.${NC}"
    else
        echo -e "${RED}Failed to create docker group. Please check your permissions.${NC}"
        exit 1
    fi
else
    echo -e "${GREEN}Docker group already exists.${NC}"
fi

if groups $USER_NAME | grep -qw docker; then
    echo -e "${GREEN}$USER_NAME is already in the docker group.${NC}"
else
    echo "$USER_NAME is not in the docker group. Adding $USER_NAME to the docker group..."
    sudo usermod -aG docker $USER_NAME
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}$USER_NAME has been added to the docker group. Please log out and back in for this to take effect.${NC}"
    else
        echo -e "${RED}Failed to add $USER_NAME to the docker group. Please check your permissions.${NC}"
    fi
fi

