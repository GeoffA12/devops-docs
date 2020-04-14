# Python Virtual Environment Configuration

[Python](https://www.python.org/) is a flexible and versatile programming language, with strengths in scripting, automation, data analysis, machine learning, and back-end development.

This tutorial will walk you through installing Python and setting up a programming environment on an Ubuntu 18.04 server. 

## Step 1: Update and Upgrade Packages 

Digital Ocean Ubuntu 18.04 environemnts come with Python pre-packaged. Update and upgrade your package manager to ensure that your shipped version of Python 3 is up-to-date. 

`sudo apt update && sudo apt upgrade --yes`

Check the version of your python library:

`python3 -V`

For the purposes of our system architecture, you want to see the following output:

`Python 3.6.9`

## Step 2: Install Pip and Additional Middleware Dependencies

Next, we need to install pip, the Python package manager that we can use for our projects.

* `sudo apt install -y python3-pip`

You can install a package via pip with the syntax 

* `pip3 install package_name_here`

We'll also need to install a few more development tools to ensure that we have a robust set-up for our programming environment

* `sudo apt install build-essential libssl-dev libffi-dev python3-dev`

## Step 3: Install venv

Virtual environments enable you to have an isolated space on your server for Python projects. We’ll use venv, part of the standard Python 3 library.

Install venv and activate the venv by typing:

* `python3.6 -m venv my_env`
* `source my_env/bin/activate`

You should see a prefix prompt with your venv custom name

`(my_env) user@ubuntu:~/environments$`

Note that within the Python 3 virtual environment, you can use the command python instead of python3, and pip instead of pip3.

Type in the command `python` and you'll know the virtual environment was set-up properly if you see the following output:

```
Python 3.6.5 (default, Apr  1 2018, 05:46:30) 
[GCC 7.3.0] on linux
Type "help", "copyright", "credits" or "license" for more information.
>>> 
```

To deactivate the virtual environment, type in

`deactivate`





