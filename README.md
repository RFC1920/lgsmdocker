# LGSMdocker
## What this is and isn't:

This repo consists of a docker compose file and Dockerfile for setting up a docker container compatible with the current (July 2026) [Rust](https://rust.facepunch.com/) game server on Linux.  Use if you have compatibility issues with your current OS (RHEL-like 9 or 10 or Ubuntu 26).

This is not a full container image ready to go, but should be enough instructions for your docker to build one for you.  This requires some knowledge of Linux and [LGSM](https://linuxgsm.com/).

## The reason this exists

I have been running a RHEL-based Linux OS at home for many years.  Recently, I upgraded to AlmaLinux 9 and found that even that was not enough to run the Rust game server.  The version of GLIBC is no longer supported.  I could upgrade to AlmaLinux 10, but then I would be missing the 32-bit libraries required to run steamcmd.

One option is to just migrate to Ubuntu or some other similar OS.  However, Ubuntu 26 also lacks 32-bit libraries for steam/steamcmd.

There are existing LGSM docker images that may work fine for you.  In my case, I need to be able to have access to the plugins within the gameserver docker.  So, we bind mount a user home directory that is dedicated to running Rust.  This allows for files to be copied or linked into the game server tree, but allows for the game server and supporting binaries to run with a compatible GLIBC.

## The solution:

What you will find here is a docker compose file to establish a basic Ubuntu 24 OS within docker.  There is also a Dockerfile whose main purpose is to install prerequisites for LGSM.

docker-compose.yaml
```yml
services:
  ubuntu:
    build:
      context: .
      dockerfile: Dockerfile
    stdin_open: true
    tty: true
    network_mode: host
    volumes:
      - /data:/data:ro
      - /home/rustserver:/home/ubuntu
```

Pretty straightforward.  I have a local directory called /data, which is where my git repos sit for various plugins
The other dir is simply the home directory for our user (rustserver in the OS, ubuntu in the container).

Dockerfile:
```dockerfile
FROM ubuntu:24.04
# Prevent interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Update the package repository and install curl
RUN dpkg --add-architecture i386
RUN apt-get update && apt-get install -y \
    curl \
    bc \
    binutils \
    bzip2 \
    cpio \
    distro-info \
    file \
    lib32gcc-s1 \
    lib32stdc++6 \
    lib32z1 \
    libsdl2-2.0-0:i386 \
    netcat-openbsd \
    pigz \
    python3 \
    unzip \
    uuid-runtime \
    wget \
    xz-utils \
    bsdmainutils \
    cron \
    cronutils \
    iproute2 \
    tmux \
    jq \
    vim \
    libgdiplus \
    mono-complete \
    && rm -rf /var/lib/apt/lists/*

RUN echo steam steam/license note '' | debconf-set-selections

RUN echo steam steam/question select "I AGREE" | debconf-set-selections

RUN apt-get update && apt-get install -y  steam steamcmd

USER ubuntu

RUN cd /home/ubuntu && curl -Lo linuxgsm.sh https://linuxgsm.sh && chmod +x linuxgsm.sh && bash linuxgsm.sh rustserver

RUN (crontab -l 2>/dev/null; echo "0 4 * * * /home/ubuntu/rustserver stop;/home/ubuntu/rustserver fu;/home/ubuntu/rustserver mu;/home/ubuntu/rustserver start") | crontab -

# Set the working directory inside the container
WORKDIR /rust

# (Optional) Copy local files from your host machine into the container
# COPY . .

# Run a default command when the container starts
#CMD ["bash"]
USER root
CMD ["cron", "-f"]
```

Here, we install various packages including lgsm and cron (for server restart scheduling).  Note, at the top of the Dockerfile, we are selecting ubuntu 24.  This hits the sweet spot currently for available security updates AND 32-bit support.

### NOTES
1. The RUN (crontab... line above includes a stop, update for rust, update for oxide, and start.  Adjust to taste if you are, e.g., NOT using oxide/carbon.
2. The libgdiplus library is optional, but needed for some plugins such as CopyPaste.cs.  mono-complete may also be optional.

## Deploy

1. Setup a local user called rustserver.  Make sure the UID and GID are 1000, which matches the default ubuntu user, ubuntu.
2. Ensure that this user can run docker, typically by adding it to the docker group.
3. As this user, checkout this repo.
4. cd into the resulting directory.
5. Run docker compose up -d
6. Assuming that worked, open a shell into the container:

```shell
docker ps # To get the container id/name
docker exec -it --user ubuntu CONTAINERID /bin/bash
```

Now, you should be able to run lgsm as usual, install and setup rust, mods, configs, etc.  See the lgsm project for instructions.

Note that now you have the entirety of the rust server and plugins, etc. in the main OS.  You can safely link to or copy plugins, configs, etc. here.

To (re)start the rust server, you will have to exec into the container as above.

