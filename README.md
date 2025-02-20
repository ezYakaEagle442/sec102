# SEC102

# Pre-req

Get some [Markdown knowledge](https://learn.microsoft.com/en-us/contribute/content/markdown-reference)

## 1.SetUp Hyper-V on Windows

### Check if your system is compatible

Read:
  - [https://techcommunity.microsoft.com/blog/educatordeveloperblog/step-by-step-enabling-hyper-v-for-use-on-windows-11/3745905](https://techcommunity.microsoft.com/blog/educatordeveloperblog/step-by-step-enabling-hyper-v-for-use-on-windows-11/3745905)
  - [https://support.microsoft.com/en-us/windows/upgrade-windows-home-to-windows-pro-ef34d520-e73f-3198-c525-d1a218cc2818](https://support.microsoft.com/en-us/windows/upgrade-windows-home-to-windows-pro-ef34d520-e73f-3198-c525-d1a218cc2818)
    
To check if your system is compatible with Hyper-V, follow these steps:

    1. Press the Windows key + R to open the Run dialog box.
    2. Type msinfo32 and press Enter.
    3. In the System Information window, scroll down to the "System Summary" section and look for the Hyper-V Requirements line. If it says "Yes", then your system is compatible


You can also check to see if the BIOS firmware has virtualization enabled by looking in the CIM_Processor class.

```bash
(Get-CimInstance win32_processor).VirtualizationFirmwareEnabled
```
```console
True
```

```bash
Get-Service vmcompute
```
```console
Status   Name               DisplayName
------   ----               -----------
Running  vmcompute          Service de calcul hôte Hyper-V
```


## 2.Enable Hyper-V on Windows 11

Once you have confirmed that your system is compatible, you can proceed to enable Hyper-V on your Windows 11 machine. Here's how:

    1. Press the Windows key + R to open the Run dialog box.
    2. Type appwiz.cpl and press Enter.
    3. In the Programs and Features window, select Turn Windows features on or off in the left-hand pane.
    4. In the Windows Features window, scroll down to Hyper-V and check the box next to it.
	5. Click on OK and wait for the installation process to complete.
	6. Once the installation is complete, click on Restart Now to restart your computer.

## 3.Configure Hyper-V settings

	Run C:\WINDOWS\System32\mmc.exe
	
    - Virtual switch: Hyper-V uses a virtual switch to connect virtual machines to your physical network. You can create a new virtual switch or use an existing one.
    - Virtual machine settings: You can configure various settings for your virtual machine, such as memory allocation, processor allocation, and network adapter settings.
    - Integration services: Hyper-V integration services enhance the performance and functionality of virtual machines. You can enable or disable integration services as needed.
     
Further resources surrounding the enablement of these resources can be found here: [https://learn.microsoft.com/training/modules/configure-manage-hyper-v/?WT.mc_id=academic-89565-abartolo](https://learn.microsoft.com/training/modules/configure-manage-hyper-v/?WT.mc_id=academic-89565-abartolo)

With automation:

```bash
C:\Windows\SysWOW64\WindowsPowerShell\v1.0\powershell.exe -ExecutionPolicy Bypass -NoExit 
Get-ExecutionPolicy
Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All

New-VMSwitch -name XXXLabXXXExternalSwitch -NetAdapterName Ethernet -AllowManagementOS $true
Get-NetAdapter -Name * -Physical
New-VMSwitch -name DockerExternalSwitch -NetAdapterName Wi-Fi -AllowManagementOS $true
```

## 4.Install VS Code 

Go to [https://code.visualstudio.com/download](https://code.visualstudio.com/download)

## 5.Install WSL2

Read [https://aka.ms/wslinstall](https://aka.ms/wslinstall)

Run Terminal :

```bash
wsl -l -v
wsl.exe --update

wsl.exe --list --online
wsl.exe --install Ubuntu-24.04
wsl.exe --install kali-linux

wsl -l -v
wsl date
# pour voir où le chemin du répertoire actif est monté dans WSL.
wsl pwd
```

```console
/mnt/c/Users/yourusername
```

## 6.Update the list of the OS products

```bash
sudo apt-get update
sudo apt upgrade --yes

uname -a 
```

```console
Linux westpoint 5.15.167.4-microsoft-standard-WSL2 #1 SMP Tue Nov 5 00:21:55 UTC 2024 x86_64 x86_64 x86_64 GNU/Linux
```

## 7.Prepare GitHub SSH Keys

Check the fingerprint of your SSH key in GitHub with the SSH Key used by git.

If your Git repo URL starts with HTTPS (ex: "https://github.com/<!XXXyour-git-homeXXX!/sec102.git"), git CLI will always prompt for password. 
When MFA is enabled on GitHub and that you plan to use SSH Keys, you have to use: git clone git@github.com:your-git-home/sec102.git

```bash
appName="sec102" 
echo "appName is : " $appName

# /!\ IMPORTANT : check & save your ssh_passphrase !!!
ssh_passphrase="<your secret>"
ssh_key="${appName}-key" # id_rsa

github_usr="<Your Git Hub Account>"
echo "GitHub user Name : " $github_usr 

git_url="git@github.com:$github_usr/$appName.git" # "https://github.com/$github_usr/xxx.git"
echo "Project git repo URL : " $git_url 

ssh-keygen --help # -t ecdsa -b 256
echo $HOME
mkdir ~/.ssh
ls -al $HOME
ssh-keygen -t rsa -b 4096 -N $ssh_passphrase -f ~/.ssh/$ssh_key -C "youremail@groland.grd"

# Check Private & Public Keys
ls -al ~/.ssh/
cat ~/.ssh/$ssh_key.pub

# Now add this PUBLIC Key to your GitHub Account as an Authentication Key: https://github.com/settings/ssh/new

# Create your Git Config

echo "
[user]
	name = bob.jojo
	email = bob.jojo@yourcorp.com
[core]
	editor = nano
	#sshCommand = ssh -i /c/Users/bob.jojo/.ssh/id_rsa
	sshCommand = ssh -i /c/Users/bob.jojo/.ssh/githubkey
	autocrlf = false

[alias]
	hist = log --all --graph --decorate --oneline

# https://git-scm.com/docs/git-config
[http]
	#proxy = http://gateway.yourcorp.zscaler.net:80
	sslVerify = true
	#sslCAInfo=/etc/ssl/certs/
	
# Since git 2.3.1, you can put https://your.domain inside an HTTP section to indicate the following certificate is only for this domain.
[http \"https://git-xxx.yourcorp.com\"]
	# Put the certificate at C:\Users\~YourUserName\AppData\Local\Programs\Git\mingw64\ssl\certs
	sslVerify = true
	sslCAInfo=/etc/ssl/certs/the_cert-tree.cer
	
[web]
	browser = firefox
	# browser = Chrome
[help]
	format = web
" >> $HOME/.gitconfig

cat $HOME/.gitconfig
# update the config as you need
vim $HOME/.gitconfig

git version
git config --list --global
# ssh -T $git_url -i /c/Users/bob.jojo/.ssh/githubkey

```

## 8.Change mount folder owner

Read :
- [https://askubuntu.com/questions/911804/ubuntu-for-windows-10-all-files-are-own-by-root-and-i-cannot-change-it](https://askubuntu.com/questions/911804/ubuntu-for-windows-10-all-files-are-own-by-root-and-i-cannot-change-it)
- [https://github.com/microsoft/WSL/issues/7798](https://github.com/microsoft/WSL/issues/7798)
  
```bash
cat /etc/group | grep $USER
# get the group of your user, ex: 1000

# Check WSL conf:
cat /etc/wsl.conf

mount | grep -i C:
# uid=0;gid=0 means it is owned by root

ls -al /etc/wsl.conf
# sudo chmod g+w /etc/wsl.conf

# Add this section in /etc/wsl.conf
[automount]
enabled = true
options = "metadata"
mountFsTab = false

cat /etc/wsl.conf 

# remount to fix the issue
sudo umount /mnt/c; sudo mount -t drvfs C: /mnt/c -o metadata,uid=1000,gid=1000
```

## 9.Clone the repository

```bash
cd $HOME
git clone $git_url
cd $appName
```

At this step, you will be able to use git in WSL, but NOT from windows, if you want to leverage VSCode/Source Control view to push your code to GitHub, then you have to complete step 10 below.

## 10.Install Gitbash for Windows

Follow this [instruction]((https://github.com/ezYakaEagle442/chocolatey/?tab=readme-ov-file#chocolatey-install)) to install [Choloatey](https://chocolatey.org/install) (package manager for Windows)

```bash
@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))" && SET "PATH=%PATH%;%ALLUSERSPROFILE%\chocolatey\bin"

choco upgrade chocolatey
choco –version
choco --help
```

Install Git bash CLI with Chocolatey
```bash
choco install git.install --Yes --confirm --accept-license
```

Open Git Bash Windows Application, create SSH Keys in Git Bash like at step 7, also configure your .gitconfig like at step 7.
```bash
hostname
whoami
date
git version
git --help
```

Test a git clone and a git push to verify your SSH Keys
```bash
cd $HOME
git clone $git_url
cd $appName
```

# Run the script

```bash
bash ./rot13.sh encode --message "Hello WORLD 2025 !"
```

```console
Have you read carefully the README file ?[Yes/No]: 
y

Feb 16 14:54:10 S01[14451]: TP02 START
Feb 16 14:54:10 S01[14451]: main START
Mot chiffré: Uryyb JBEYQ 2025 !

Feb 16 14:54:10 S01[14451]: main END
Feb 16 14:54:10 S01[14451]: TP02 END
```

```bash
bash ./rot13.sh decode --message "Uryyb JBEYQ 2025 !"
```
```console
Have you read carefully the README file ?[Yes/No]: 
y

Feb 16 15:06:25 S01[14895]: TP02 START
Feb 16 15:06:25 S01[14895]: main START
Mot déchiffré: Hello WORLD 2025 !

Feb 16 15:06:25 S01[14895]: main END
Feb 16 15:06:25 S01[14895]: TP02 END
```

## TP3
```bash
bash ./rot13.shu get-hive
```
```console
Have you read carefully the README file ?[Yes/No]: 
y

Feb 16 21:50:39 S01[1631]: TP02 START
Feb 16 21:50:39 S01[1631]: main START
Feb 16 21:50:39 S01[1631]: get_ua_psh START
Feb 16 21:50:39 S01[1631]: Fichier créé avec succès!
Feb 16 21:50:39 S01[1631]: decode_ua_file START
Feb 16 21:50:39 S01[1631]: decode_ua_file END
Feb 16 21:50:39 S01[1631]: get_ua_psh END
Feb 16 21:50:39 S01[1631]: main END
Feb 16 21:50:39 S01[1631]: TP02 END
```