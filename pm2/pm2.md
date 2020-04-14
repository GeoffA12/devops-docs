## PM2 Server Configuration

PM2 is a daemon process manager that will help you manage and keep your applications online 24/7. 

PM2 was developed to manage Node.js applications, but we can take advantage of PM2's flexibility in our PoC to persist our python back-end web services. 

We install PM2 through npm, the default package manager for the Node.js library. Thus, as a dependency, we'll need to first install Node.js onto our digital ocean droplet. 

For context on Node.js, Node.js is an open-source JavaScript runtime environment for building server-side and networking applications. The platform runs on Linux, macOS, FreeBSD, and Windows. Though you can run Node.js applications at the command line, this tutorial will focus on running them as a service. This means that they will restart on reboot or failure and are safe for use in a production environment.

## Prerequisites

You should already have the following setup:

* An [Ubuntu v18.04 droplet](/README.md) configured.
* [Python](python/python.md) Installed and upgraded on your server. 
* A python back-end service that you want to persist on your server. For this tutorial, i'll be using `team22cswebservice.py` as our placefiller. 

## Step 1: Install Nodejs v12

et’s begin by installing the latest LTS release of Node.js, using the NodeSource package archives.

First, install the NodeSource PPA in order to get access to its contents. Make sure you’re in your home directory, and use curl to retrieve the installation script for the Node.js 12.x archives:

```
cd ~
curl -sL https://deb.nodesource.com/setup_12.x -o nodesource_setup.sh
sudo bash nodesource_setup.sh
```

The PPA will be added to your configuration and your local package cache will be updated automatically. After running the setup script from Nodesource, you can install the Node.js package:

* `sudo apt install nodejs`

Make sure to check your versions of Node.js and npm to see if they were installed properly. 

```
nodejs -v
v12.16.1
npm -v
6.13.4
```

We'll need an additional isntall through npm for some of our pm2 packages to function properly: 

* `sudo apt install build-essential`

You now have all the necessary packages to host your python applications with PM2. 


## PM2 Installation and Configuration

Next let’s install PM2. PM2 makes it possible to daemonize applications so that they will run in the background as a service.

`sudo npm install pm2@latest -g`

The -g option tells npm to install the module globally, so that it’s available system-wide.

Lets maneuver to the folder where you have `team22cswebservice.py` located. 

`cd /var/www/demand.team22.softwareengineeringii.com/html/common-services`

Now, we'll need to use the `pm2 start` command to tell the PM2 daemon manager to start our application as a background thread. 

`pm2 start team22cswebservice.py --name csAPI --interpreter=python3`

Note that whenever we first fire up a python web service, we MUST include the **python interpreter we want the application to run on**. PM2 doesn't know this automatically so we must specify it. 

Also, the name parameter `csAPI` in the start command is optional, but I find that it gives you an easier time issuing PM2 commands as we'll see later. 

You should see an output dump on your terminal similar to the following: 

```
[PM2] Starting /var/www/supply.team22.softwareengineeringii.com/html/common-services/team22cswebservice.py in fork_mode (1 instance)
[PM2] Done.
┌─────┬───────────────────────────┬─────────────┬─────────┬─────────┬──────────┬────────┬──────┬───────────┬──────────┬──────────┬──────────┬──────────┐
│ id  │ name                      │ namespace   │ version │ mode    │ pid      │ uptime │ ↺    │ status    │ cpu      │ mem      │ user     │ watching │
├─────┼───────────────────────────┼─────────────┼─────────┼─────────┼──────────┼────────┼──────┼───────────┼──────────┼──────────┼──────────┼──────────┤
│ 22  │ csAPI                     │ default     │ N/A     │ fork    │ 27460    │ 0s     │ 0    │ online    │ 0%       │ 7.3mb    │ team22   │ disabled │
└─────┴───────────────────────────┴─────────────┴─────────┴─────────┴──────────┴────────┴──────┴───────────┴──────────┴──────────┴──────────┴──────────┘
[PM2][WARN] Current process list running is not in sync with saved list. Type 'pm2 save' to synchronize or enable autosync via 'pm2 set pm2:autodump true'
```

The warning issued at the bottom of the output is telling us to sync the current configuration of PM2 with our global PM2 configuration settings. Follow the instructions:

* `pm2 set pm2:autodump true`

Now we're ready to learn a few commands we'll be needing throughout the course to work with PM2. 

## Step 3 Learn useful PM2 commands

PM2 provides many subcommands that allow you to manage or look up information about your applications.

To stop the application we previously started, issue the `stop` command:

`pm2 stop csAPI`

To restart the application,

`pm2 restart csAPI`

Both of these commands will come in handy when debugging system testing errors on the server. 

Another command you'll find very useful is the `list` command which will list out all of your current applications managed by PM2 and their associated configurations.

`pm2 list`

If you see a `status: errored` value in after issuing your `pm2 start` command, the likely issues is that either your application has a bug in the source code, or you mistyped the start command. 

To debug, I suggest checking the `pm2 logs --json` file or running your script manually on the server to see if any errors are raising.




