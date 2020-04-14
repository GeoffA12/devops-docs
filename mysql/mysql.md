# MySQL and Docker-Compose Integration
[Back to main docs](/README.md)

With Docker Compose, we get all the benefits of Docker plus more. Docker works by creating a virtual environment(or container) for your code to run. What Docker Compose adds is orchestration and organization of multiple containers. While this tutorial will only spin up a single container for our MySQL instance, Docker Compose can also be used to run all of your various services at once when your project begins to grow out.

# Prerequisites:

First off, you'll need to compelete the [Docker installation guide for Ubuntu 18.04 in entirety](docker/docker.md). 

Next, we'll need to issue a command to install docker-compose onto our host system. 

* `sudo curl -L "https://github.com/docker/compose/releases/download/1.22.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose && sudo chmod +x /usr/local/bin/docker-compose`

Make sure that your installation was setup correctly: 

`docker-compose --version`

You should see something similar to:

`docker-compose version 1.22.0, build 1719ceb`

## Setting up Docker-Compose with MySQL

We need to create a `docker-compose.yaml` configuration file for our Docker container to execute on our host system. This file is essentially an instruction sheet for Docker. To learn more about docker-compose yaml configuration files, refer to the [official Docker Docs website](https://docs.docker.com/compose/).

Next, we'll need to issue a few commands to build the docker container and run it on our system. 

Inside the folder where the docker-compose file exists, run the command:

* `sudo docker-compose up --build`

This command will build the image onto our system so that we can then use docker-compose to create a container running on our host machine. 

Next, run the docker container as a background thread:

* `sudo docker-compose up -d`

This command might take a while on the first run because Docker needs to pull the MySQL containers from a Docker repository online. 

After the command is executed, we now have access to mysql on our system.

[Back to main docs](/README.md)