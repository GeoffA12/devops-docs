# Docker Configuration

Docker is an application that simplifies the process of managing application processes in containers. Containers let you run your applications in resource-isolated processes. They’re similar to virtual machines, but containers are more portable, more resource-friendly, and more dependent on the host operating system.

For a detailed introduction to the different components of a Docker container, check out The Docker Ecosystem: An Introduction to Common Components.

In this tutorial, you’ll install and use Docker Community Edition (CE) on Ubuntu 18.04. You’ll install Docker itself and setup a user account with access to docker commands.

# Prerequisites

To follow this guide, you'll need the following: 

 * One Ubuntu 18.04 server set up by following the [Ubuntu 18.04 initial server setup guide](../README.md), including a sudo non-root user.

Eventually, you'll be needing to work with docker images and push them to the docker hub, or pull images off of the docker hub. Therefore, it is highly recommended to [make an account on the Docker Hub](https://hub.docker.com/) prior to starting the guide.


## Step 1: Install Docker
The Docker installation package available in the official Ubuntu repository may not be the latest version. To ensure we get the latest version, we’ll install Docker from the official Docker repository. To do that, we’ll add a new package source, add the GPG key from Docker to ensure the downloads are valid, and then install the package.

First, update your existing list of packages and install a few prerequistite packages over apt:

* `sudo apt update`
* `sudo apt install apt-transport-https ca-certificates curl software-properties-common`

Next, add the GPG key for the official Docker repo onto your system and the docker repository to APT sources:

* `curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -`
* `sudo apt sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic stable"`

Now we can update our package manager with packages from the new Docker repo and install Docker.

```
sudo apt update
sudo apt install docker-ce
```

Docker should now be installed onto your host machine and running as a daemon thread, with the process enabled on boot startup.
Check that the service is running with:

* `sudo systemctl status docker`

You should see ouput on the terminal similar to the folllowing:

```
● docker.service - Docker Application Container Engine
   Loaded: loaded (/lib/systemd/system/docker.service; enabled; vendor preset: enabled)
   Active: active (running) since Thu 2018-07-05 15:08:39 UTC; 2min 55s ago
     Docs: https://docs.docker.com
 Main PID: 10096 (dockerd)
    Tasks: 16
   CGroup: /system.slice/docker.service
           ├─10096 /usr/bin/dockerd -H fd://
           └─10113 docker-containerd --config /var/run/docker/containerd/containerd.toml
```
## Step 2: Executing the Docker Command Without Sudo (Optional) 

By default, the `docker` command can only be run the root user or by a user in the docker group, which is automatically created during Docker’s installation process. If you attempt to run the `docker` command without prefixing it with sudo or without being in the docker group, you’ll get an output like this:

```
Output
docker: Cannot connect to the Docker daemon. Is the docker daemon running on this host?.
See 'docker run --help'.
```

If you want to avoid typing sudo whenever you run the docker command, add your username to the docker group:

`sudo usermod -aG docker ${USER}`
`su - ${USER}`

You will be prompted to enter your user’s password to continue.

Confirm that your user is now added to the docker group by typing:

`id -nG`

You should see output similar to the following: 

`yourcustomuser sudo docker`

You now no longer have to preface docker with the `sudo` prefix when issuing commands when logged in as this new user. 

## Step 3: Using the Docker Command

Using docker consists of passing it a chain of options and commands followed by arguments. The syntax takes this form:

`docker [option] [command] [arguments]`

To view available subcommands, type:

`docker`

You should see a list of subcommands: 

```
  attach      Attach local standard input, output, and error streams to a running container
  build       Build an image from a Dockerfile
  commit      Create a new image from a container's changes
  cp          Copy files/folders between a container and the local filesystem
  create      Create a new container
  diff        Inspect changes to files or directories on a container's filesystem
  events      Get real time events from the server
  exec        Run a command in a running container
  export      Export a container's filesystem as a tar archive
  history     Show the history of an image
  images      List images
  import      Import the contents from a tarball to create a filesystem image
  info        Display system-wide information
  inspect     Return low-level information on Docker objects
  kill        Kill one or more running containers
  load        Load an image from a tar archive or STDIN
  login       Log in to a Docker registry
  logout      Log out from a Docker registry
  logs        Fetch the logs of a container
  pause       Pause all processes within one or more containers
  port        List port mappings or a specific mapping for the container
  ps          List containers
  pull        Pull an image or a repository from a registry
  push        Push an image or a repository to a registry
  rename      Rename a container
  restart     Restart one or more containers
  rm          Remove one or more containers
  rmi         Remove one or more images
  run         Run a command in a new container
  save        Save one or more images to a tar archive (streamed to STDOUT by default)
  search      Search the Docker Hub for images
  start       Start one or more stopped containers
  stats       Display a live stream of container(s) resource usage statistics
  stop        Stop one or more running containers
  tag         Create a tag TARGET_IMAGE that refers to SOURCE_IMAGE
  top         Display the running processes of a container
  unpause     Unpause all processes within one or more containers
  update      Update configuration of one or more containers
  version     Show the Docker version information
  wait        Block until one or more containers stop, then print their exit codes
```

To view system-wide information about Docker use, 

`docker info`

## Step 4 Check out the Docker Docs to get started with Images

Docker containers are built from Docker images. By default, Docker pulls these images from [Docker Hub](https://hub.docker.com/), a Docker registry managed by Docker, the company behind the Docker project. Anyone can host their Docker images on Docker Hub, so most applications and Linux distributions you’ll need will have images hosted there.

To learn more about working with docker images and containers, check out [the official Docker documentation website](https://docs.docker.com/)
