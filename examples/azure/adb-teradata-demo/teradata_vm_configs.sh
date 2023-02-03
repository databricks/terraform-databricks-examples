#!/bin/bash
sudo -i
mkdir /opt/downloads
cd /opt/downloads

parted /dev/sdc --script mklabel gpt mkpart xfspart xfs 0% 100%
mkfs.xfs /dev/sdc1
partprobe /dev/sdc1
export DISK_UUID=$(blkid | grep sdc1 | cut -d"\"" -f2)
echo "UUID=$DISK_UUID  /opt/downloads   xfs   defaults,nofail   1   2" >> /etc/fstab

apt update && apt-get install p7zip-full p7zip-rar virtualbox -y

curl -o ve.7z 'https://d289lrf5tw1zls.cloudfront.net/database/teradata-express/VantageExpress17.20_Sles12_20220819081111.7z?Expires=1673417382&Signature=tiXioXzo0wg53m6ELyXenLwOeWPZFeYV4rAZIM3qw886SkkK67Pb8mHCr~jHza7FTrMfeZXTXtnis4x7WEbXsmQCfkRo2~zv97n9oE1kDiOVYRt7b61xORtPJPyVKMUs4mbebgJEl8gOAO-wqIWSmBs~mA4wZyb2X63dHcE70R2wyFHwwiiZzlcC-bb7wYuZe0emT4aTeGW6ndXXEKvGSK~OCIXx5uLNqboRAaIS0BksEOl8HjP6iYurue~kNkIGtlG3rW~XtBkfvL7hpTPG7RF1z7zvG1XXtMyxMfLXu-lt4JnCl4jodjGD8iszh6LZ28TubyIXz1y9kBYF-aq3mQ__&Key-Pair-Id=xxxxxxxx'

7z x ve.7z

export VM_IMAGE_DIR="/opt/downloads/VantageExpress17.20_Sles12"
DEFAULT_VM_NAME="vantage-express"
VM_NAME="${VM_NAME:-$DEFAULT_VM_NAME}"
vboxmanage createvm --name "$VM_NAME" --register --ostype openSUSE_64
vboxmanage modifyvm "$VM_NAME" --ioapic on --memory 6000 --vram 128 --nic1 nat --cpus 4
vboxmanage storagectl "$VM_NAME" --name "SATA Controller" --add sata --controller IntelAhci
vboxmanage storageattach "$VM_NAME" --storagectl "SATA Controller" --port 0 --device 0 --type hdd --medium  "$(find $VM_IMAGE_DIR -name '*disk1*')"
vboxmanage storageattach "$VM_NAME" --storagectl "SATA Controller" --port 1 --device 0 --type hdd --medium  "$(find $VM_IMAGE_DIR -name '*disk2*')"
vboxmanage storageattach "$VM_NAME" --storagectl "SATA Controller" --port 2 --device 0 --type hdd --medium  "$(find $VM_IMAGE_DIR -name '*disk3*')"
vboxmanage modifyvm "$VM_NAME" --natpf1 "tdssh,tcp,,4422,,22"
vboxmanage modifyvm "$VM_NAME" --natpf1 "tddb,tcp,,1025,,1025"
vboxmanage startvm "$VM_NAME" --type headless
vboxmanage controlvm "$VM_NAME" keyboardputscancode 1c 1c
