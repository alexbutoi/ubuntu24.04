#!/bin/bash

read -p "Enter disk size (e.g., 64G): " DISK_SIZE
read -p "Enter number of CPU cores: " CPU
read -p "Enter memory size in MB: " MEM
read -p "Enter VM ID: " VMID
read -p "Enter VM name: " VM_NAME
read -s -p "Enter password for Cloud-Init user: " CLEARTEXT_PASSWORD
echo
IMAGE_URL="https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img"
IMAGE_NAME="noble-server-cloudimg-amd64.img"
BRIDGE="vmbr0"
STORAGE="local-lvm"

wget $IMAGE_URL -O $IMAGE_NAME

qemu-img resize $IMAGE_NAME $DISK_SIZE

# Create a new VM
qm create $VMID \
  --name "$VM_NAME" \
  --ostype l26 \
  --memory $MEM \
  --agent 1 \
  --bios ovmf \
  --machine q35 \
  --efidisk0 ${STORAGE}:0,pre-enrolled-keys=0 \
  --socket 1 \
  --cores $CPU \
  --vga serial0 \
  --serial0 socket \
  --net0 virtio,bridge=$BRIDGE

qm importdisk $VMID $IMAGE_NAME $STORAGE
qm set $VMID \
  --scsihw virtio-scsi-pci \
  --virtio0 ${STORAGE}:vm-${VMID}-disk-1,discard=on,ssd=1

qm set $VMID --boot order=virtio0
qm set $VMID --ide2 ${STORAGE}:cloudinit
qm set $VMID --tags VM,Linux,Ubuntu,CloudInit
qm set $VMID --ciuser sysadmin
qm set $VMID --cipassword $(openssl passwd -6 $CLEARTEXT_PASSWORD)
qm set $VMID --ipconfig0 ip=dhcp
qm template $VMID
echo "VM Template $VM_NAME ($VMID) created successfully."
