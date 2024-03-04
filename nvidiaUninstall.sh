#!/bin/bash
#
# Remove the nvidia drivers installed with nvidiaSetup.sh

sudo apt purge 'nvidia*' 'libnvidia*' 'cuda*' 'libcuda*'
sudo apt --fix-broken -y install
sudo apt autoremove -y

