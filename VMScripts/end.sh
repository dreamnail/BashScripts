#!/bin/bash
set -x

# Load variables
source "/etc/libvirt/hooks/kvm.conf"

# Unload vfio-pci
modprobe -r vfio_pci
modprobe -r vfio_iommu_type1
modprobe -r vfio

# Re-Bind GPU to Nvidia Driver
virsh nodedev-reattach $VIRSH_GPU_VIDEO
virsh nodedev-reattach $VIRSH_GPU_AUDIO
virsh nodedev-reattach $VIRSH_GPU_USB
virsh nodedev-reattach $VIRSH_GPU_SERIALBUS


# Rebind VT consoles
echo 1 > /sys/class/vtconsole/vtcon0/bind
# Some machines might have more than 1 virtual console.
#echo 1 > /sys/class/vtconsole/vtcon1/bind

nvidia-xconfig --query-gpu-info > /dev/null 2>&1

echo "efi-framebuffer.0" > /sys/bus/platform/drivers/efi-framebuffer/bind

# Load nvidia 
modprobe  nvidia_drm
modprobe  nvidia_modeset
modprobe  drm_kms_helper
modprobe  nvidia
modprobe  drm
modpobe  nvidia_uvm

# Restart Display Manager
systemctl start display-manager.service

