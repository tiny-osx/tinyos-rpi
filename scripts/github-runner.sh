#!/bin/bash

# Abort script if any command returns error
set -e

RUNNER_USER="<USER>"
RUNNER_TOKEN="<TOKEN>"

# Install required packages
sudo apt-get update
sudo apt-get upgrade
sudo apt-get install -y language-pack-en
sudo apt-get install -y gawk wget git diffstat unzip texinfo gcc build-essential \
  chrpath socat cpio python3 python3-pip python3-pexpect xz-utils debianutils \
  iputils-ping python3-git python3-jinja2 libegl1-mesa libsdl1.2-dev \
  xterm python3-subunit mesa-common-dev zstd liblz4-tool file htop

# Create a runner user
sudo adduser --system --no-create-home --group $RUNNER_USER

# Create runner folder
sudo mkdir -p /opt/github/tinyos-rpi

# Change runner folder ownership
sudo chown -R $RUNNER_USER:$RUNNER_USER /opt/github/tinyos-rpi

# Download the latest runner package
sudo -u $RUNNER_USER bash -c '\
    cd /opt/github/tinyos-rpi && \
    curl -o actions-runner-linux-x64-2.316.0.tar.gz -L https://github.com/actions/runner/releases/download/v2.316.0/actions-runner-linux-x64-2.316.0.tar.gz && \
    tar xzf ./actions-runner-linux-x64-2.316.0.tar.gz && \
    rm -f ./actions-runner-linux-x64-2.316.0.tar.gz'

# Create the runner and start the configuration experience
sudo -u $RUNNER_USER ./config.sh --url https://github.com/tiny-osx/tinyos-rpi --token $RUNNER_TOKEN

# Setup runner as a service
sudo ./svc.sh install $RUNNER_USER

# Start the service
sudo ./svc.sh start

# Check the status of the service
sudo ./svc.sh status

# You can tail the relevant service log
# journalctl -u actions.runner.tiny-osx-tinyos-rpi.bitbake.service -n 100
