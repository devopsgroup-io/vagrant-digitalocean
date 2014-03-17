#!/bin/bash
#
# Bootstrap python
sudo=
if [ 0 != `id -u` ]; then
  sudo=sudo
fi

if which python > /dev/null 2>&1; then
  echo Python installed
elif which yum > /dev/null 2>&1; then
  echo Installing python with yum
  $sudo yum install -y python
elif which pacman > /dev/null 2>&1; then
  echo Installing python2 with pacman
  $sudo pacman -Sy
  $sudo pacman -S --noconfirm --needed python2
  if [ ! -f /usr/bin/python ]; then
    $sudo ln -nfs /usr/bin/python2 /usr/bin/python
  fi
elif which apt-get > /dev/null 2>&1; then
  echo Installing python with apt-get
  $sudo apt-get -y update
  $sudo apt-get -y install python
elif which easy_install > /dev/null 2>&1; then
  echo Installing python with easy_install / pip
  if ! which pip > /dev/null 2>&1; then
    $sudo easy_install pip
  fi
  $sudo pip install python
else
  echo Unable to install python 
  exit 1
fi
python --version
