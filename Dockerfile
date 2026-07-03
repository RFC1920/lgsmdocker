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
