#!/bin/bash

getYesOrNo()
{
    local answer
    read -r answer
    while [[ $answer != "y" && $answer != "n" ]]; do
        echo "Invalid input. Please enter 'y' or 'n'."
        read -r answer
    done
    echo "$answer"
}

getGPUDrivers()
{
	#add support for amd
   echo "installing nvidia drivers for any GPU found in 2014 and later .."
   dnf update -y # and reboot if you are not on the latest kernel
   dnf install akmod-nvidia # rhel/centos users can use kmod-nvidia instead
   dnf install xorg-x11-drv-nvidia-cuda #optional for cuda/nvdec/nvenc support
}

if [[ "$EUID" -ne 0 ]]; then 
    echo "Please run as root"
  exit
fi

echo "MAKE SURE YOUR SYSTEM IS UPDATED BEFORE RUNNING THIS SCRIPT!"
echo "You are running $(cat /etc/fedora-release). This script was built for Fedora 37. Would you like to continue? (y/n)"
answer=$(getYesOrNo)

if [[ $answer == "n" ]]; then
    echo "Exiting script."
    sleep 3
    exit 1
fi

## Install things that should come pre-installed with Fedora 

echo "Installing RPM Fusion..."
dnf install -y "https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm"
echo "Installing multimedia codecs..."
dnf groupupdate multimedia -y --setop="install_weak_deps=False" --exclude=PackageKit-gstreamer-plugin
dnf groupupdate -y sound-and-video

## Install VM software

echo "Would you like to install and setup virtualization software? (y/n)"
answer=$(getYesOrNo)

if [[ $answer == "y" ]]; then

   if [[ 8 -ge $(grep -E '^flags.*(vmx|svm)' /proc/cpuinfo | wc -l | awk '{if ($1 < 10) system("echo this message means nothing and i should prob find a better way to do this" )}' | wc -w) ]]; then
       echo "Install virtualization software.." && dnf group install -y --with-optional virtualization && systemctl start libvirtd && systemctl enable libvirtd || echo "Install failed."
       echo "Verifying KVM kernel modules. You should see kvm_intel or kvm_amd here.. "
       lsmod | grep kvm
       sleep 5
   else
	echo "this system does not support the relevant virtualization extensions"
   fi
   
fi

## Install GPU driver

echo "your current GPU is.. $(lspci |grep VGA)" 
echo "would you like to install nvidia gpu drivers? y/n"
answer=$(getYesOrNo)

if [[ $answer == "y" ]]; then
    lspci | grep -q "NVIDIA" && getGPUDrivers || echo "did not find \"NVIDIA\" in lspci are you sure you would like to continue? y/n"
    answer=$(getYesOrNo)
   if [[ $answer == "y" ]]; then
	   getGPUDrivers
   fi
fi

