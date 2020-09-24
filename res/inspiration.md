Setup and run a Virtual Lab on a system with minimal resources


During this COVID-19 pandemic, I've found myself taking the path of bug bounty hunting and web app testing - so far so good. 
However, I  currently work as an IT Support Engineer. Anyways, that's just a tip of whoami.txt{head whoami.txt}.

I've had prior experience with web app technologies and development during my sophomore year and throughout my undergraduate years. 
After a couple of research and youtubing I chose to dive into WAPT/BBHT. 
Unfortunately, I encounter my first challenge, my Dell laptop running on an i5 4th generation chooses to fail. One of the motherboard's IC fails.

With my evergrowing thirst to learn, i choose to find a way. I do have a Lenovo G-50 laptop with a 2GB RAM running on Intel Celeron N2840 (2) @ 2.582GHz that i had contemplated selling. 
It feels quite the downgrade coming from a 3.30GHz of processing speed and an 8GB RAM capacity but i have no other option and financially can't quite afford a new one at the moment.

The laptop is fairly new and without a battery{desktop mode}. 
I need to find a memory efficient Desktop environment for Kali Linux OS. Fortunately there is an ISO with such a DE on their site - XFCE Desktop Environment. 
I download burn and install it effortlessy.I'm not new to linux and it's learning curve isn't arduous as some folks make it sound - at least for a curious mind. 

This is a 64Bit OS on a 2GB RAM and it's not a big deal if you choose to use it with its default software. 
However, if you choose to customize and add new packages, you might wanna reconsider adding more RAM - can't afford the luxury.
For my case i have virtualization software(VirtualBox), burpsuite(bundled with Java), Chrome, Visual Studio Code, Telegram, Discord and other memory intensive software that i need to install. 
This poses a challenge and i have to find a solution at the moment before i can afford to boost the RAM or acquire a new machine.

Objective: To be able to create and have a lab enviroment to further my learning
Target Software: VirtualBox

	What do I want to achieve?
 	- To be able to set up labs - vulnerable web apps, for practice 
	What do I have? Is it enough?
	- A lenovo G-50 laptop with Intel Celeron N2840 (2) @ 2.582GHz running on 2GB RAM. 
	- Yes and no. Yes if i choose to be creative. No if i know not much about the software i wanna use
	How do i overcome the challenge?
	- To create and launch virtual machines in headless mode 


I findout that i can create manage, start, stop and configure networking of virtual machines using VirtualBox VBoxManage command line utilities.
One can create and launch the virtual machines in headless mode minimizing the memory overhead. This is great if the virtual machine O.S comes with no GUI(minimal install) like Ubuntu Server Edition. It is also a big win if you are a terminal warrior.

	Steps
	- To Install VirtualBox and dependencies{dkms vboxmanage utilities etc}
	{ Installer script @ GitHub > source inspiration from https://www.kali.org/docs/virtualization/install-virtualbox-kali-host/}
	- To Download and Install ubuntu server{ i choose bionic beaver LTS}
	{https://releases.ubuntu.com/18.04/ubuntu-18.04.4-live-server-amd64.iso}
	- To set up networking {virtual network: host only interface} assign static ip to virtual machine 
	- To create an alias to start the VM - add it to .bashrc file and source the file
	- To use ssh to manage the vm and start vulnerable Web Apps
		can also create an ssh alias {My ssh alias}
	Why Aliases? to avoid the repeatitive work of typing long commands

At the end of the day i ended up creating a script to automate the creation and installation of virtual machines. {src github}
Kindly download and try it. Leave me feedback on [email]

That is how VirtualBox command line utilities saved my day and aliases relieved me typing long commands :-)

Reference Material

https://www.virtualbox.org/svn/vbox/trunk/src/VBox/Main/UnattendedTemplates/debian_postinstall.sh
https://renenyffenegger.ch/notes/Companies-Products/Oracle/VM-VirtualBox/command-line/PowerShell/unattended-os-installation
https://www.virtualbox.org/ticket/18411
https://kifarunix.com/how-to-automate-virtual-machine-installation-on-virtualbox/



