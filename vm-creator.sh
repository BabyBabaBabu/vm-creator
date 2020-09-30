#!/usr/bin/env bash
# vm-creator.sh
# A bash script that automates unattended 
# creation and installation of a VirtualBox Virtual Machine
# Author: BabyBabaBabu

# Source config file with variable names
. vm.conf
# VM storage folder
#VMDIR=`VBoxManage list systemproperties | awk -F":" '/Default machine folder/  { print $2 }' | sed -e 's/^[ \t]*//'`
OS_TYPE="`cat /etc/os-release | grep -E "ID_LIKE" | sed -e 's/ID_LIKE=//'`"
P_MANAGER=""
P_INSTALLER=""

function osCheck(){
# Check OS Type and substitute with suitable package manager & package installer
    #debian based OS 
    if [[ "$OS_TYPE" -eq "debian"]];then
        P_MANAGER="dpkg -s"
        P_INSTALLER="apt-get -qq install"
    #centos based OS
    elif [[ "$OS_TYPE" -eq "rhel fedora" ]];then
        P_MANAGER="rpm -q"
        P_INSTALLER="yum install"
    #arch based OS
    elif [[ "$OS_TYPE" -eq "archlinux" || "$OS_TYPE" -eq "arch" ]];then
        P_MANAGER="pacman -Qi"
        P_INSTALLER="pacman -S"
    else
        echo -e "Unknown OS Type"
    fi
# Check if dependencies already met & satisfy them
   depCheck
}

function depCheck(){
    if $P_MANAGER virtualbox &>/dev/null ;then
        return 0
    else
        echo -e "installing..."
        sudo $P_INSTALLER virtualbox
    fi
}

# Create the VM
function createVM(){
    echo -e "\n [+] Creating Virtual Machine \n"
    VBoxManage createvm --name $VBOX_NAME --ostype $OS_TYPE --register
    echo -e "\n [+] Setting Up Storage media \n"
    VBoxManage createmedium disk --filename "/home/kitaa/VirtualBox VMs/$VBOX_NAME/$VBOX_NAME.vhd" --size $D_SIZE --format $D_FORM --variant $D_VARIANT
}
# Create storage
function addModifications(){
    
    echo -e "\n [+] Add SATA Storage Controllers for VM HDD \n"
    VBoxManage storagectl $VBOX_NAME --name SATA --add SATA --controller IntelAhci
    echo -e "\n [+] Attach SATA Storage Controller \n"
    VBoxManage storageattach $VBOX_NAME --storagectl SATA --port 0 --device 0 --type hdd --medium "/home/kitaa/VirtualBox VMs/$VBOX_NAME/$VBOX_NAME.vhd"
    echo -e "\n [+] Add IDE Storage Controllers for DVD Drive \n"
    VBoxManage storagectl $VBOX_NAME --name IDE --add ide
    echo -e "\n [+] Attach ISO File to IDE Storage Controller \n"
    VBoxManage storageattach $VBOX_NAME --storagectl IDE --port 0 --device 0 --type dvddrive --medium $OS_ISO
    echo -e "\n [+] Allocate RAM and VRAM \n"
    VBoxManage modifyvm $VBOX_NAME  --memory $MEM_SIZE --vram 16
    echo -e "\n [+] Enable IO APIC \n"
    VBoxManage modifyvm $VBOX_NAME --ioapic on
    echo -e "\n [+] Disable USB USB2.0, USB3.0 controllers \n"
    VBoxManage modifyvm $VBOX_NAME --usb off
    VBoxManage modifyvm $VBOX_NAME --usbehci off
    VBoxManage modifyvm $VBOX_NAME --usbxhci off
    echo -e "\n [+] Setting Up Display Graphics Controller \n"
    VBoxManage modifyvm  $VBOX_NAME --graphicscontroller $DISP_CTRL
    echo -e "\n [+] Specify boot order, 1st: dvd \n"
    VBoxManage modifyvm $VBOX_NAME --boot1 dvd --boot2 disk --boot3 none --boot4 none
    
}

# Set up networking
function addNetworking(){

    echo -e "\n [+] Setting Up Networking \n"
    echo -e "\n [+] Available Host-Only Interfaces \n"
    VBoxManage list hostonlyifs | grep -w "Name:" | awk '{print$2}'
    echo -e "\n [+] Creating new Host-Only Interface \n"
    V_NET=$(VBoxManage hostonlyif create > /tmp/intf; grep -o 'vboxnet[[:alnum:]]' < /tmp/intf; rm /tmp/intf)
    echo  "Interface created: $V_NET"
    VBoxManage hostonlyif ipconfig $V_NET --ip $GATEWAY
    echo -e "\n [+] Adding Interfaces to VM \n"
    VBoxManage modifyvm $VBOX_NAME --nic2 nat --nic1 hostonly --hostonlyadapter1 $V_NET
    echo -e "\n [+] Setting Up DHCP Server for created Host-Only Interface \n"
    VBoxManage dhcpserver add --interface=$V_NET --server-ip=$DHCPSRV --netmask=$NETMASK --lower-ip=$L_LEASE --upper-ip=$U_LEASE --enable --global --vm=$VBOX_NAME --fixed-address=$VM_IP
    
}

# Installation
function doInstall(){

    echo -e "\n [+] Installation started \n"
    VBoxManage unattended install ${VBOX_NAME} --full-user-name="$FNAME" --user="$UNAME" --password="$PASSWORD" --locale=$LOCALE --country=$COUNTRY --time-zone=$T_ZONE  --hostname="$FQDN" --iso=$OS_ISO --install-additions --additions-iso=$G_ADDS 
    echo -e "\n [+] Start $VBOX_NAME VM \n"
    VBoxManage startvm $VBOX_NAME --type $S_MODE
    echo -e "\n [+] Checking if $VBOX_NAME is running \n"
    VBoxManage list runningvms | grep $VBOX_NAME

    echo -e "\n [+] Wait for installation to finish \n"
    VBoxManage guestproperty wait $VBOX_NAME /VirtualBox/GuestInfo/Net/0/V4/IP 2>&1 /dev/null
    echo -e "\n [+] Installation complete! "
    # Returns valid IP Address assigned to VM
    address=`VBoxManage guestproperty get $VBOX_NAME /VirtualBox/GuestInfo/Net/0/V4/IP | grep -Eo "(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)" `
    echo -e "\n [+] Access \"$VBOX_NAME\" VM on Host-Only Interface \"$V_NET\" at \"$address\" \n"
    
}

# Check if similar VM Exists
function checkExist(){
    echo -e "[+] Performing virtual machine check..."
    if [[ `VBoxManage list vms | grep $VBOX_NAME` ]];then
        U_UID=`VBoxManage list vms | grep $VBOX_NAME | awk -F" " '{print $2}'`
        echo -e "\n[!!] VM with similar name exists its UUID is $U_UID.\n"
        read -p "[*] Would you like to delete it?(Y/N)" resp
	        if [[ $resp == "Y" || $resp == "y" ]];then
	            echo -e "\n[+] Unregistering & deleting $VBOX_NAME.\n"
                if [[ `VBoxManage list runningvms | grep $VBOX_NAME` ]];then
                    VBoxManage controlvm ${VBOX_NAME} poweroff soft 2>&1 /dev/null
                    VBoxManage unregistervm ${VBOX_NAME} --delete 2>&1 /dev/null
                else
                    VBoxManage unregistervm ${VBOX_NAME} --delete 2>&1 /dev/null
                fi
	        elif [[ $resp == "N" || $resp == "n" ]];then
	            echo -e "\n[!!] Edit the vm.conf file and change the VBOX_NAME value!\n"
	        else
	            echo -e "\n[!!] Unknown option $resp, try Y\\y or N\\\n. \n"
	        fi
    else
    	echo -e "\n[+] Proceeding with set up..."
    fi
}

# Logging
function runSetUp(){
    echo -e "[+] Started: "`date +"%H-%M-%S-%d-%m-%y"`
    osCheck
    checkExist
    createVM
    addModifications
    addNetworking
    doInstall
    echo -e "[+] Completed: "`date +"%H-%M-%S-%d-%m-%y"`
}

T_STAMP=`date +"%H-%M-%S-%d-%m-%y"`
mkdir -p logs
LOG_FILE=logs/$VBOX_NAME-"Installation"-$T_STAMP.log
runSetUp | tee $LOG_FILE


