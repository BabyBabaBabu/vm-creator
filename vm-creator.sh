#!/usr/bin/env bash

# Source config file with variable names
. vm.conf
# VM storage folder
#vmDIR=`VBoxManage list systemproperties | awk -F":" '/Default machine folder/  { print $2 }' | sed -e 's/^[ \t]*//'`


# Create the VM
echo -e "\n [+] Creating Virtual Machine \n"
VBoxManage createvm --name $VBoxName --ostype $osType --register
echo -e "\n [+] Setting Up Storage media \n"
VBoxManage createmedium disk --filename "/home/kitaa/VirtualBox VMs/$VBoxName/$VBoxName.vhd" --size $diskSize --format $form --variant $varian

# Create storage
echo -e "\n [+] Add SATA Storage Controllers for VM HDD \n"
VBoxManage storagectl $VBoxName --name SATA --add SATA --controller IntelAhci
echo -e "\n [+] Attach SATA Storage Controller \n"
VBoxManage storageattach $VBoxName --storagectl SATA --port 0 --device 0 --type hdd --medium "/home/kitaa/VirtualBox VMs/$VBoxName/$VBoxName.vhd"
echo -e "\n [+] Add IDE Storage Controllers for DVD Drive \n"
VBoxManage storagectl $VBoxName --name IDE --add ide
echo -e "\n [+] Attach ISO File to IDE Storage Controller \n"
VBoxManage storageattach $VBoxName --storagectl IDE --port 0 --device 0 --type dvddrive --medium $osISO
echo -e "\n [+] Allocate RAM and VRAM \n"
VBoxManage modifyvm $VBoxName  --memory $memSize --vram 16
echo -e "\n [+] Enable IO APIC \n"
VBoxManage modifyvm $VBoxName --ioapic on
echo -e "\n [+] Disable USB USB2.0, USB3.0 controllers \n"
VBoxManage modifyvm $VBoxName --usb off
VBoxManage modifyvm $VBoxName --usbehci off
VBoxManage modifyvm $VBoxName --usbxhci off
echo -e "\n [+] Setting Up Display Graphics Controller \n"
VBoxManage modifyvm  $VBoxName --graphicscontroller $dispCtrl
echo -e "\n [+] Specify boot order, 1st: dvd \n"
VBoxManage modifyvm $VBoxName --boot1 dvd --boot2 disk --boot3 none --boot4 none

# Set up networking
echo -e "\n [+] Setting Up Networking \n"
echo -e "\n [+] Available Host-Only Interfaces \n"
VBoxManage list hostonlyifs | grep -w "Name:" | awk '{print$2}'
echo -e "\n [+] Creating new Host-Only Interface \n"
vNet=$(VBoxManage hostonlyif create > /tmp/intf; grep -o 'vboxnet[[:alnum:]]' < /tmp/intf; rm /tmp/intf)
echo  "Interface created: $vNet"
VBoxManage hostonlyif ipconfig $vNet --ip $gateWay
echo -e "\n [+] Adding Interfaces to VM \n"
VBoxManage modifyvm $VBoxName --nic2 nat --nic1 hostonly --hostonlyadapter1 $vNet
echo -e "\n [+] Setting Up DHCP Server for created Host-Only Interface \n"
VBoxManage dhcpserver add --interface=$vNet --server-ip=$dhcpServer --netmask=$netMask --lower-ip=$lowLease --upper-ip=$upLease --enable --global --vm=$VBoxName --fixed-address=$vmIP

# Installation
echo -e "\n [+] Installation started \n"
VBoxManage unattended install ${VBoxName} --full-user-name="$fullUname" --user="$Uname" --password="$Password" --locale=$Locale --country=$Country --time-zone=$Zone  --hostname="$Fqdn" --iso="/home/kitaa/Downloads/iso/ubuntu-18.04.4-server-amd64.iso" --install-additions --additions-iso="/home/kitaa/.config/VirtualBox/VBoxGuestAdditions_6.1.8.iso"
echo -e "\n [+] Start $VBoxName VM \n"
VBoxManage startvm $VBoxName --type $startMode
echo -e "\n [+] Checking if $VBoxName is running \n"
VBoxManage list runningvms | grep $VBoxName

echo -e "\n [+] Wait for installation to finish \n"
VBoxManage guestproperty wait $VBoxName /VirtualBox/GuestInfo/Net/0/V4/IP 2>&1 /dev/null
# Returns valid IP Address assigned to VM
address=`VBoxManage guestproperty get $VBoxName /VirtualBox/GuestInfo/Net/0/V4/IP | grep -Eo "(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)" `
echo -e "\n [+] Installation complete! "
echo -e "\n [+] Access \"$VBoxName\" VM on Host-Only Interface \"$vNet\" at \"$address\" \n"





