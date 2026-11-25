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
    #steamcmd \

RUN echo steam steam/license note '' | debconf-set-selections
RUN echo steam steam/question select "I AGREE" | debconf-set-selections
RUN apt-get update && apt-get install -y steam steamcmd

# 2. Copy the entrypoint script into the container
COPY entrypoint.sh /usr/local/bin/entrypoint.sh

# 3. Give execution permissions to the script (while still root)
RUN chmod +x /usr/local/bin/entrypoint.sh

# Run commands as ubuntu user
USER ubuntu
# Set the working directory inside the container
WORKDIR /home/ubuntu
RUN curl -Lo linuxgsm.sh https://linuxgsm.sh && chmod +x linuxgsm.sh && bash linuxgsm.sh rustserver
RUN (crontab -l 2>/dev/null; echo "0 4 * * * /home/ubuntu/rustserver stop;/home/ubuntu/rustserver fu;/home/ubuntu/rustserver mu;/home/ubuntu/rustserver start") | crontab -

RUN /usr/local/bin/entrypoint.sh

# Run cron as root when the container starts
USER root
CMD ["cron", "-f"]
