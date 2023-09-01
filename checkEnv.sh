#!/bin/bash

os_packages=(
    "docker.io" 
    "docker-compose"
    "jq"
    "xmlstarlet"
    )

missing_packages=()

installPackage(){

    PACKAGE_NAME=$1
    echo "Would you like to install $PACKAGE_NAME [y/n]"
    read answer

    case $answer in
    [Yy]* ) echo "Installing $package";
        if [ $UPDATE_DONE -eq 0 ]; then
            echo "Updating APT repository"
            sudo apt-get update
            UPDATE_DONE=1   
        fi
            sudo apt-get install $PACKAGE_NAME
        ;;

    [Nn]* ) echo "Skipping $package";;

    * ) echo "Invalid choice.";; 
    esac
}

packageStatus(){
    PACKAGE_NAME=$1
    if dpkg -l | grep -q "^ii\s\+$PACKAGE_NAME\s"; then
        return 1
    else
        return 0
    fi
}

displayStatus(){
    for package in "${os_packages[@]}"; do
        packageStatus $package
        if [ $? -eq 0 ]; then
            status="\033[0;31mMissing\033[0m"
            missing_packages+=("$package")
        else
            status="\033[0;32mLoaded\033[0m"
        fi
        echo -e $package ":   [" $status "]"
    done
}

getGPUInfo(){

# Fetch GPU information in XML format
xml_output=$(nvidia-smi -q -x| sed '/<!DOCTYPE/d')
echo "here"
# Parse XML to get GPU name, driver version, and temperature
gpu_name=$(echo "$xml_output" | xmlstarlet sel -t -v "//gpu/product_name")
driver_version=$(echo "$xml_output" | xmlstarlet sel -t -v "//driver_version")
cuda_version=$(echo "$xml_output" | xmlstarlet sel -t -v "//cuda_version")
number_gpu=$(echo "$xml_output" | xmlstarlet sel -t -v "//attached_gpus")
gpu_memory=$(echo "$xml_output" | xmlstarlet sel -t -v "//fb_memory_usage/total")


# Print the extracted values
echo "GPU Name: $gpu_name"
echo "number of GPU: $number_gpu"
echo "Driver Version: $driver_version"
echo "Cuda Version: $cuda_version"
echo "GPU memory: $gpu_memory"
}

UPDATE_DONE=0
clear
displayStatus

for package in "${missing_packages[@]}"; do
    installPackage $package
done

displayStatus
getGPUInfo