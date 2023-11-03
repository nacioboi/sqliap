# Pick a title lol.

## Table of Contents

- (1) [Introduction](#1-introduction)
- (2) [Prerequisites](#2-prerequisites)
  - (2.2) [Required Operating System](#21-required-operating-system)
  - (2.2) [Required Software](#22-required-software)
  - (2.3) [For Windows Users](#23-for-windows-users)
- (3) [Preparing an Environment](#3-preparing-an-environment)
  - (3.1) [Setting Up VirtualBox on Windows](#31-setting-up-virtualbox-on-windows)
  - (3.2) [Understanding 'Flavors' of Linux](#32-understanding-flavors-of-linux)
  - (3.3) [Installing Git, among other things](#33-installing-git-among-other-things)
  - (3.4) [Setting up Docker Volume and MySQL Database](#34-setting-up-docker-volume-and-mysql-database)
- (4) [Cloning the Repository](#4-cloning-the-repository)
- (5) [Building the Docker Image](#5-building-the-docker-image)
- (6) [Starting the Container](#6-starting-the-container)
- (7) [Accessing the App](#7-accessing-the-app)
- (8) [Stopping the Container](#8-stopping-the-container)
- (9) [:warning: !! IMPORTANT !! :warning:](#9-warning--important--warning)
- (10) [Stopping the Container](#10-stopping-the-container)
- (11) [A few things to node while inside our container...](#11-a-few-things-to-node-while-inside-our-container)

---

## (1) Introduction

Welcome to an **SQL Login Example project**! I'm bad at names so im calling it `myhttp` This app is a basic web application that
demonstrates **how to implement user authentication using MySQL**, Node.js, and Docker.

The goal is to keep this example as **simple as possible** to help newcomers understand how websites and SQL databases interact.
So, if you're new to these technologies, don't worry — we've got a detailed guide to help you get up and running.

Let's dive in! 🌊

---

## (2) Prerequisites

### (2.1) Required Operating System

- [X] Unix-based system (Linux, macOS). Either on bare metal or virtual machine.

### (2.2) Required Software

- [X] `Make`;
- [X] `Docker`;
- [X] `Node.js`; and,
- [X] `Git`.

#### Node.js packages:

- [X] `express` for the web server; and,
- [X] `mysql` for interacting with the database.

### (2.3) For Windows Users

- VirtualBox for setting up a Unix-based environment inside virtual machine.

You may use whatever virtualization software you like, but this guide will be using VirtualBox as it is free, open-source, and lots of
tutorials are available online.

We will provide a small guide on how to set up VirtualBox on Windows.

---

## (3) Preparing an Environment

### (3.1) Setting up VirtualBox on Windows

#### Skip this if already on a Unix-based system.

- Download and [install VirtualBox](https://www.virtualbox.org/wiki/Downloads).
- Download a Unix-based ISO (e.g., Ubuntu).
  - An AU mirror located [here](https://gsl-syd.mm.fcix.net/ubuntu-releases/).
- Create a new VM and install the Unix OS.
  - If you don't feel like searching youtube for a tutorial, [click here](https://www.youtube.com/watch?v=hYaCCpvjsEY).
- Install Docker within this VM.

### (3.2) Understanding 'Flavors' of Linux

There are different 'flavors' of Linux with three big 'daddies' of linux and these are:

- Debian;
- Red Hat; and,
- Arch.

Ubuntu is a flavor of Debian and Docker has different installation instructions for each flavor of linux.
You can find more about linux [here](https://www.youtube.com/watch?v=KyADkmRVe0U).

- To install Docker within the virtual machine:
  - Assuming you installed Ubuntu, you can follow the instructions [here](https://docs.docker.com/engine/install/ubuntu/).

### (3.3) Installing Git, among other things

#### First, about system update and upgrade...

On most linux systems, you can update or upgrade your system and these are different things.
Most linux system have something called a package manager, it is the tool that you use to install software and upgrade software.

These package managers pull from a url to get a list of software that you can install and upgrade.
This list is called a repository and it is a list of software that is maintained by the linux distribution.

- So then, update means to update the repository list of software that you can install and upgrade.
- And upgrade means to upgrade the software that you have installed.

On other systems, like MacOS, there is no upgrade, only update but on linux, there is both.

#### An example to explain the difference between update and upgrade...

Say you want to upgrade your Ubuntu system.

You can run the following command to upgrade all packages on your system:

```bash
sudo apt upgrade
```

But, here, you made a critical mistake. You forgot to update your system first.
This means that the system upgrade will only upgrade to the latest packages your repository listing has currently.
Meaning then, that there might still be newer packages that you can upgrade to but you won't be able to upgrade to them because your repository listing is out of date.

So, before running a system upgrade, you should always run a system update first:

```bash
sudo apt update
```

#### Installing them...

First, update your system:

- On debian-based systems (i.e., Ubuntu), run `sudo apt update`.
- On arch-based systems (i.e., Manjaro), run `sudo pacman -Sy`.

Then, install the following software:

- For Debian-based systems (i.e, Ubuntu), `sudo apt install git nodejs make`.
- For Arch-based systems (i.e., Manjaro), `sudo pacman -S git nodejs make`.

### (3.4) Setting up Docker Volume and MySQL Database

- Create a new Docker volume:

```bash
sudo docker volume create mysqlv
```

`mysqlv` stands for MySQL Volume. :D

- Spin up a temporary container to set up MySQL:

```bash
sudo docker run --name mysqltc -e MYSQL_ROOT_PASSWORD=passwd -v mysqlv:/var/lib/mysql -d mysql:latest
```

- Connect to MySQL from the temporary container and setup your database.

```bash
sudo docker exec -it mysqltc bash
```

Then, while inside your container:

```bash
mysql -u root -p
```

It will then prompt you for a password. Enter `passwd` and hit enter. You should now be inside the MySQL CLI. Run the following commands:

```sql
CREATE DATABASE mydb; 			-- Create a database called 'mydb'.
USE mydb; 				-- Switch to the database you just created.
CREATE TABLE users (
	username VARCHAR(255),
	passwd VARCHAR(255)
);
```

- Add some users to the database:

```sql
INSERT INTO users (username, passwd) VALUES ('user1', 'password1');
INSERT INTO users (username, passwd) VALUES ('user2', 'password2');
INSERT INTO users (username, passwd) VALUES ('user3', 'password3');
```

- Exit the MySQL CLI and the container:

```sql
exit
```

Once exited the SQL CLI, exit the container:

```bash
exit
```

---

## (4) Cloning the Repository

Once you have all the prerequisites installed, you can clone the repository...

- Run:

```bash
git clone https://github.com/nacioboi/myhttp.git
```

- Move into the directory:

```bash
cd myhttp
```

### 5. Building the Docker Image

- First, we must run a script to fetch the latest node.js:

```bash
make init
```

- Then we can build the docker image:

```bash
make build
```

This will require sudo privileges.

### 6. Starting the Container

- Run:

```bash
make run
```

---

## To run steps %5 and %6 in one command...

- Simply:

```bash
make
```

### 7. Accessing the App

Open your web browser and go to `http://localhost:80`.

### 8. Stopping the Container

### 9. :warning: !! IMPORTANT !! :warning:

#### WHEN EXITING THE CONTAINER, PLEASE WAIT FOR THE `.start_container.sh` SCRIPT TO FINISH THE PROCESS!!

The script will take a few seconds to cleanup the container. If you exit the container before the script finishes, you will have to manually remove the container.

### 10. Stopping the Container

Is simply a matter of exiting bash.

```bash
exit
```

### 11. A few things to node while inside our container...

#### Log files

- The log files are located in the `/usr/var/http` directory.
  - `node.log` is the log file for the node.js server.
  - `sqld.log` is the log file for the mysql server.

The root of the project is located in `/usr/var/http/myhttp`.
