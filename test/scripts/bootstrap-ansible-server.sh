#!/bin/bash
#
# Bootstrap ansible

if which ansible > /dev/null 2>&1; then
  echo ansible installed
elif which yum > /dev/null 2>&1; then
  echo Installing ansible with yum
  sudo yum install -y ansible
elif which pacman > /dev/null 2>&1; then
  echo Installing ansible with pacman
  sudo pacman -Sy
  sudo pacman -S --noconfirm --needed ansible
elif which apt-get > /dev/null 2>&1; then
  echo Installing ansible with apt-get
  sudo apt-add-repository -y ppa:rquillo/ansible
  sudo apt-get -y update
  sudo apt-get -y install ansible
elif which easy_install > /dev/null 2>&1; then
  echo Installing ansible with easy_install / pip
  if ! which pip > /dev/null 2>&1; then
    sudo easy_install pip
  fi
  sudo pip install ansible
else
  echo Unable to install ansible 
  exit 1
fi
ansible --version
