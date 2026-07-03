# LGSMdocker

## The reason this exists

I have been running a RHEL-based Linux OS at home for many years.  Recently, I upgraded to AlmaLinux 9 and found that even that was not enough to run the Rust game server.  The version of GLIBC is no longer supported.  I could upgrade to AlmaLinux 10, but then I would be missing the 32-bit libraries required to run steamcmd.

One option is to just migrate to Ubuntu or some other similar OS.  However, Ubuntu 26 also lacks 32-bit libraries for steam/steamcmd.

There are existing LGSM docker images that may work fine for you.  In my case, I need to be able to have access to the plugins within the gameserver docker.  So, we bind mount a user home directory that is dedicated to running Rust.  This allows for files to be copied or linked into the game server tree, but allows for the game server and supporting binaries to run with a compatible GLIBC.

## The solution:

What you will find here is a docker compose file to establish a basic Ubuntu 24 OS within docker.  There is also a Dockerfile whose main purpose is to install prerequisites for LGSM.

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
      - /export:/export:ro
      - /home/rustserver:/home/ubuntu
```

Pretty straightforward.  I have a local directory called /export, which is where my git repos sit for various plugins
The other dir is simply the home directory for our user (rustserver in the OS, ubuntu in the container).

## Deploy

1. Setup a local user called rustserver.  Make sure the UID and GID are 1000, which matches the default ubuntu user, ubuntu.
2. As this user, checkout this repo.
3. cd into the resulting directory.
4. Run docker compose up -d
5. Assuming that worked, open a shell into the container:

```shell
docker ps # To get the container id/name
docker exec -it --user ubuntu CONTAINERID /bin/bash
```

Now, you should be able to run lgsm as usual, install and setup rust, mods, configs, etc.  See the lgsm project for instructions.

Note that now you have the entirety of the rust server and plugins, etc. in the main OS.  You can safely link to or copy plugins, configs, etc. here.

To (re)start the rust server, you will have to exec into the container as above.

