#!/bin/bash
set -x

# Load variables
source "/etc/libvirt/hooks/kvm.conf"

# Stop display manager
systemctl stop display-manager.service
killall gdm-x-session
pulse_pid=$(pgrep -u j pulseaudio)
pipewire_pid=$(pgrep -u j pipewire)
kill $pulse_pid
kill $pipewire_pid

# Unbind VTconsoles
echo 0 > /sys/class/vtconsole/vtcon0/bind
echo 0 > /sys/class/vtconsole/vtcon1/bind

# Unbind EFI-Framebuffer
echo efi-framebuffer.0 > /sys/bus/platform/drivers/efi-framebuffer/unbind

# Avoid a Race condition
sleep 5

# unload Nvidia
modprobe -r nvidia_drm
modprobe -r nvidia_modeset
modprobe -r drm_kms_helper
modprobe -r nvidia
modprobe -r i2c_nvidia_gpu
modprobe -r drm
modpobe -r nvidia_uvm

# Unbind the GPU from display driver
virsh nodedev-detach $VIRSH_GPU_VIDEO
virsh nodedev-detach $VIRSH_GPU_AUDIO
virsh nodedev-detach $VIRSH_GPU_USB
virsh nodedev-detach $VIRSH_GPU_SERIALBUS

# Load VFIO Kernel Module
modprobe vfio
modprobe vfio_pci
modprobe vfio_iommu_type1


