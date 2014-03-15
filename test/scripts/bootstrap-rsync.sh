#!/bin/bash
#
# Bootstrap scripts from 

bootstrap_arch()
{
  echo This bootstraps rsync on Arch Linux.
  #
  set -e

  # Verify we're running as root
  if [ "$EUID" -ne "0" ]; then
    echo "This script must be run as root." >&2
    exit 1
  fi

  # Update the pacman repositories
  pacman -Sy

  # Install rsync 
  gem install rsync --no-ri --no-rdoc --no-user-install
  echo "rsync has been installed!"
}


bootstrap_centos_or_fedora()
{
  #!/usr/bin/env bash
  echo This bootstraps rsync on CentOS/Fedora

  set -e

  if [ "$EUID" -ne "0" ]; then
    echo "This script must be run as root." >&2
    exit 1
  fi

  # Install rsync
  echo "Installing rsync"
  yum install -y rsync > /dev/null

  echo "rsync has been installed!"
}

bootstrap_debian_or_ubuntu()
{
  #!/usr/bin/env sh

  echo This bootstraps rsync on Debian or Ubuntu
  set -e

  # Do the initial apt-get update
  echo "Initial apt-get update..."
  apt-get update >/dev/null

  if [ "$EUID" -ne "0" ]; then
    echo "This script must be run as root." >&2
    exit 1
  fi

  # Install rsync
  echo "Installing rsync"
  apt-get install -y rsync >/dev/null

  echo "rsync has been installed!"
}

if which rsync > /dev/null 2>&1; then
  echo "rsync is already installed."
elif which pacman > /dev/null 2>&1; then
  bootstrap_arch
elif which rpm > /dev/null 2>&1 && which yum > /dev/null 2>&1; then
  bootstrap_centos_or_fedora
elif which dpkg > /dev/null 2>&1 && which apt-get > /dev/null 2>&1; then
  bootstrap_debian_or_ubuntu
else
  echo 'Unable to determine distribution!'
  exit 1
fi
rsync --version
