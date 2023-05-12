#!/bin/bash
set -x

echo "You are running $(cat /etc/fedora-release). This script was built on Fedora 37. Would you like to continue? (y/n)"
read -r answer

## REPLACE WITH FUNCTION
while [[ $answer != "y" && $answer != "n" ]]
do
    echo "Invalid input. Please enter 'y' or 'n'."
    read -r answer
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

## REPLACE WITH FUNCTION
while [[ $answer != "y" && $answer != "n" ]]
do
    echo "Invalid input. Please enter 'y' or 'n'."
    read -r answer
done

if [[ $answer == "y" ]]; then
    echo "Installing virtualization software..."
    sudo dnf install @virtualization && sudo systemctl start libvirtd && sudo systemctl enable libvirtd || echo "Install failed."
    echo "Verifying KVM kernel modules. You should see kvm_intel or kvm_amd here:"
    lsmod | grep kvm
fi

## Install GPU drivers 

