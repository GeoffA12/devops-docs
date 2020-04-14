# Server Configuration Guide

This guide is written for setting up droplets on Digital Ocean for Software Engineering 1 at St. Edward's University for Spring 2020. While there is a lot of information here, it is very important that you complete EVERY step in order to get a stable, and fully functional environment. Make sure to continue on to the MongoDB, NodeJS and Nginx pages as they have additional setup information.

## Software Versions:
 
 * nginx: 1.14.0/Ubuntu
 * Ubuntu: 18.04 x64
 * MySQL: v8.0.19
 * Docker: v18.09.7
 * Python: v3.6.9
 * certbot: 0.31.0
 * npm: 6.13.4

Program versions can be checked by calling `[program-name] --version`, or if that doesn't return it, `[program-name] -v`.

## Important Definitions And Terms

 * `~` : This character refers to the current signed-in user's home directory on Linux/UNIX machines (e.g. if the current signed in user is `team23`, `~` is the same as `/home/team23`). This also works on Windows using Powershell, but not the Command Prompt (`cmd.exe`), and is recognixed on Macs. All of our servers for this course use Ubuntu (a Linux distribution) so the `~` is a valid way to get the user's home directory. In Powershell, `~` refers to your user home directory, which is `C:\Users\[your-username]`.
 * `pwd` : pwd is the UNIX command for "present working directory". Calling this command will print out where you currently are in the system (useful if you think a file or folder should be there but you aren't sure where you are).
 * `mv [source-file-or-directory] [destination-file-or-directory]` : mv is the unix command for "move". It takes a source and a destination, and is also used to rename a file. Passing just a file name or directory name wihout a full path will implicitly use the current path that the terminal is at (which can be shown with `pwd`).
 * `cd [directory]` : cd is the unix command for "change directory". This changes the current directory your terminal is looking at to the directory specified. This command can take an absolute path which starts with either `/` or `~` (e.g. `cd /etc/nginx/` or `~/.ssh/`) or can take a path *relative to the directory you are currently in* (e.g. you are in a directory with a subdirectory called "supply", you can say `cd supply` and you will descend into that folder). 
 * `sudo` : sudo stands for "switch user do". This command allows for executing single commands as a user with elevated permissions on the system, without being logged into that elevated account all the time.
 * `apt` : The package manager on Ubuntu. This is the command for installing/removing/updating software and applications on Ubuntu.


## SSH into Server

The first time you go to ssh into a new Digital Ocean server, the only default user is the `root` user, so that is who we shall sign in as for the purpose of this guide. You should create other accounts and disable logging in as `root` as a security best practice, but that is outside the scope of this guide and will come later on. This guide makes no assumptions that you are running as a user without elevated privelages. 

SSH tutorials are defined below, based on your operating system. If you are using a recent version of Windows 10 (1803 or later, checkable in Settings>System>About this PC), your machine already has OpenSSH installed by default. If you are on an older version of Windows, see the section on using PuTTY below.

### Using OpenSSH (MacOS, Windows 10 Version 1803+, Linux)

We will be connecting to the server using the key-pair we created at the beginning of this guide. Digital Ocean handled adding the key to the droplet for us, so we are good to connect in using the key, our `root` user, and our domain name that we set up in the last section. The ssh command should be formatted as follows, and should be run from the same terminal as used for `ssh-keygen`.  

 - MacOS: `Terminal.app`, found in Applications/ folder
 - Windows: `Powershell`, openable using `Windows + R` keys on the keyboard, and typing 'powershell' in the dialog box that appears and hitting enter
 - Linux: Your terminal emulator of choice (ensure that you have ssh packages installed, if you'ure using a Linux distribution as your primary OS then you should be able to do this)

```
ssh -i ~/.ssh/id_rsa root@[domain-name-or-ip]
```

On your first SSH connection, the system will ask if you'd like to accept the authenticity of the host. Say yes to this

*Reminder: The key generated above defaults to* `id_rsa`*, however if you are using a different keypath on your machine substitude in that path for* `~/.ssh/id_rsa`.

## Updating and Installing Packages on a Newly Created Server

If you succesfully logged into the server for the first time, it is time to update the packages and package repositories (lists of packages that can be installed on the system) to the most recent version using the following commands, and add more repositories we will need on the system. Make sure to do these one at a time (the last line is really 2 commands, strung together with `&&`. This will run both commands back to back). You may receive a couple popups in the terminal that asks if you would like to overwrite a file. If so, choose "keep the local version currently installed".

```
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 9DA31620334BD75D9DCB49F368818C72E52529D4
sudo add-apt-repository universe
sudo apt-add-repository ppa:certbot/certbot --yes
sudo apt update && sudo apt upgrade --yes
```

Now it is time to install the rest of the applications and middleware needed to complete the server configuration, as well as remove any previously installed packages that are installed but no longer needed.

```
sudo apt install nginx-full certbot python-certbot-nginx --yes
sudo apt autoremove --yes
```

`NodeJS` and `npm` installation and configuration can be found in the [NodeJS Documentation](https://github.com/nodesource/distributions/blob/master/README.md). 

## Python Virtual Environment Configuration 

* [MongoDB Docs](python/python.md)

## Nginx Server Configuration

* [Nginx Docs](nginx/nginx.md)

## Docker Setup

* [MySQL Docs](docker/docker.md)

## MySQL Setup with Docker-Compose

* [MySQL Docker Docs](mysql/mysql.md)

## Nodejs PM2 Setup

* [PM2 Docs](pm2/pm2.md)

