#!/bin/bash
set -x

function getGPUDrivers()
{
   echo "installing nvidia drivers for any GPU found in 2014 and later .."
   sudo dnf update -y # and reboot if you are not on the latest kernel
   sudo dnf install akmod-nvidia # rhel/centos users can use kmod-nvidia instead
   sudo dnf install xorg-x11-drv-nvidia-cuda #optional for cuda/nvdec/nvenc support
}

echo "You are running $(cat /etc/fedora-release). This script was built for Fedora 37. Would you like to continue? (y/n)"
read -r answer

## REPLACE WITH FUNCTION
while [[ $answer != "y" && $answer != "n" ]]
do
    echo "Invalid input. Please enter 'y' or 'n'."
    read -r answer
    sleep 5
done

if [[ $answer == "y" ]]; then
    echo "Checking if system is up to date..."
    echo "If prompted to restart after, please do so."
    sudo dnf update -y
    sleep 5
else
    echo "Exiting script."
    return 1
fi

## Install things that should come pre-installed with Fedora 

echo "Installing RPM Fusion..."
sudo dnf install -y "https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm"
echo "Installing multimedia codecs..."
sudo dnf groupupdate multimedia -y --setop="install_weak_deps=False" --exclude=PackageKit-gstreamer-plugin
sudo dnf groupupdate -y sound-and-video

## Install VM software

echo "Would you like to install and setup virtualization software? (y/n)"
read -r answer

while [[ $answer != "y" && $answer != "n" ]]
do
    echo "Invalid input. Please enter 'y' or 'n'."
    read -r answer
done

if [[ $answer == "y" ]]; then

    grep -E '^flags.*(vmx|svm)' /proc/cpuinfo | wc -l | awk '{if ($1 < 10) system("echo this system does not support the relevant virtualization extensions")}' && return 2
    echo "Install virtualization software.."
    sudo dnf group install --with-optional virtualization && sudo systemctl start libvirtd && sudo systemctl enable libvirtd || echo "Install failed."
    echo "Verifying KVM kernel modules. You should see kvm_intel or kvm_amd here.. "
    lsmod | grep kvm
    sleep 3
fi

## Install GPU driver

echo "your current GPU is.. $(lspci |grep VGA)" 
echo "would you like to install nvidia gpu drivers? y/n"
read -r answer

while [[ $answer != "y" && $answer != "n" ]]
do	
    echo "Invalid input. Please enter 'y' or 'n'."
    read -r answer
done
if [[ $answer == "y" ]]; then
    lspci | grep -q "NVIDIA" && getGPUDrivers || echo "did not find \"NVIDIA\" in lspci are you sure you would like to continue? y/n"
    read -r answer 
    while [[ $answer != "y" && $answer != "n" ]]
do
    echo "Invalid input. Please enter 'y' or 'n'."
    read -r answer
done
   if [[ $answer == "y" ]]; then
	   getGPUDrivers
   fi
fi


