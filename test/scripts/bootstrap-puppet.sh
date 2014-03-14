#!/bin/bash
#
# Thanks to bootstrap scripts from 
# https://github.com/hashicorp/puppet-bootstrap
# and
# https://github.com/robinbowes/puppet-server-bootstrap/blob/master/psb (for fedora)

bootstrap_arch()
{
  echo This bootstraps Puppet on Arch Linux.
  #
  set -e

  # Verify we're running as root
  if [ "$EUID" -ne "0" ]; then
    echo "This script must be run as root." >&2
    exit 1
  fi

  # Update the pacman repositories
  pacman -Sy

  # Install Ruby
  pacman -S --noconfirm --needed ruby

  # Install Puppet and Facter
  gem install puppet facter --no-ri --no-rdoc --no-user-install

  # Create the Puppet group so it can run
  groupadd puppet

  cp `gem contents puppet | grep puppet.service` /usr/lib/systemd/system
}


bootstrap_centos_5_x()
{
  #!/usr/bin/env bash
  echo This bootstraps Puppet on CentOS 5.x
  # It has been tested on CentOS 5.6 64bit

  set -e

  REPO_URL="http://yum.puppetlabs.com/el/5/products/i386/puppetlabs-release-5-7.noarch.rpm"

  if [ "$EUID" -ne "0" ]; then
    echo "This script must be run as root." >&2
    exit 1
  fi

  # Install puppet labs repo
  echo "Configuring PuppetLabs repo..."
  repo_path=$(mktemp)
  wget --output-document="${repo_path}" "${REPO_URL}" 2>/dev/null
  rpm -i "${repo_path}" >/dev/null

  # Install Puppet...
  echo "Installing puppet"
  yum install -y puppet > /dev/null

  echo "Puppet installed!"
}

bootstrap_centos_6_x()
{
  echo This bootstraps Puppet on CentOS 6.x
  # It has been tested on CentOS 6.4 64bit

  set -e

  REPO_URL="http://yum.puppetlabs.com/el/6/products/i386/puppetlabs-release-6-7.noarch.rpm"

  if [ "$EUID" -ne "0" ]; then
    echo "This script must be run as root." >&2
    exit 1
  fi

  # Install puppet labs repo
  echo "Configuring PuppetLabs repo..."
  repo_path=$(mktemp)
  wget --output-document="${repo_path}" "${REPO_URL}" 2>/dev/null
  rpm -i "${repo_path}" >/dev/null

  # Install Puppet...
  echo "Installing puppet"
  yum install -y puppet > /dev/null

  echo "Puppet installed!"
}

rpm_installed () {
  rpm -q --quiet $1
}


download(){
  if ! curl --fail --location --silent "$1" -o "$2"; then
    echo "Error downloading $1" 
    exit 2
  fi
}

bootstrap_fedora()
{
  echo This bootstraps Puppet on Fedora

  set -e

  PUPPETLABS_REPO_BASE=http://yum.puppetlabs.com
  REDHAT_RELEASE=/etc/redhat-release
  EPEL_REPO_BASE=http://dl.fedoraproject.org/pub/epel
  TEMP_DIR=${TEMP:-/tmp}
  MODULE_DIR="${TEMP_DIR}/modules"

  declare -A PUPPETLABS_RELEASE=(
  ["fedora/f17"]="7"
  ["fedora/f18"]="7"
  ["fedora/f19"]="2"
  ["el/5"]="7"
  ["el/6"]="7"
)

  URL_FAMILY="fedora/f"
  OS_MAJOR_VERSION=${OS_VERSION%%.*}
  FAMILY_VERSION="${URL_FAMILY}${OS_MAJOR_VERSION}"
  PUPPETLABS_RPM_RELEASE="${PUPPETLABS_RELEASE["$FAMILY_VERSION"]}"
  if [[ -z $PUPPETLABS_RPM_RELEASE ]] ; then
    error "puppetlabs release rpm not known for $FAMILY_VERSION" 101
  fi

  # retrieve the release RPM and install it
  PUPPETLABS_RELEASE_NAME="puppetlabs-release-${OS_MAJOR_VERSION}-${PUPPETLABS_RPM_RELEASE}"
  PUPPETLABS_RELEASE_RPM="${PUPPETLABS_RELEASE_NAME}.noarch.rpm"
  if rpm_installed "${PUPPETLABS_RELEASE_NAME}" ; then
    echo "${PUPPETLABS_RELEASE_NAME} installed"
  else
    PUPPETLABS_REPO_URL="${PUPPETLABS_REPO_BASE}/${FAMILY_VERSION}/products/i386/${PUPPETLABS_RELEASE_RPM}"
    download "${PUPPETLABS_REPO_URL}" "${TEMP_DIR}/$PUPPETLABS_RELEASE_RPM"
    yum -y localinstall "${TEMP_DIR}/$PUPPETLABS_RELEASE_RPM"
  fi

  if rpm_installed puppet ; then
    echo "puppet installed"
  else
    yum -y install puppet
  fi
}

bootstrap_debian()
{
  #!/usr/bin/env sh

  echo This bootstraps Puppet on Debian
  set -e

  # Do the initial apt-get update
  echo "Initial apt-get update..."
  apt-get update >/dev/null

  # Older versions of Debian don't have lsb_release by default, so 
  # install that if we have to.
  which lsb_release || apt-get install -y lsb-release

  # Load up the release information
  DISTRIB_CODENAME=$(lsb_release -c -s)

  REPO_DEB_URL="http://apt.puppetlabs.com/puppetlabs-release-${DISTRIB_CODENAME}.deb"

  #--------------------------------------------------------------------
  # NO TUNABLES BELOW THIS POINT
  #--------------------------------------------------------------------
  if [ "$EUID" -ne "0" ]; then
    echo "This script must be run as root." >&2
    exit 1
  fi

  # Install wget if we have to (some older Debian versions)
  echo "Installing wget..."
  apt-get install -y wget >/dev/null

  # Install the PuppetLabs repo
  echo "Configuring PuppetLabs repo..."
  repo_deb_path=$(mktemp)
  wget --output-document="${repo_deb_path}" "${REPO_DEB_URL}" 2>/dev/null
  dpkg -i "${repo_deb_path}" >/dev/null
  apt-get update >/dev/null

  # Install Puppet
  echo "Installing Puppet..."
  apt-get install -y puppet >/dev/null

  echo "Puppet installed!"
}

bootstrap_ubuntu()
{
  #!/usr/bin/env bash
  #
  # This bootstraps Puppet on Ubuntu 12.04 LTS.
  #
  set -e

  # Load up the release information
  . /etc/lsb-release

  REPO_DEB_URL="http://apt.puppetlabs.com/puppetlabs-release-${DISTRIB_CODENAME}.deb"

  #--------------------------------------------------------------------
  # NO TUNABLES BELOW THIS POINT
  #--------------------------------------------------------------------
  if [ "$(id -u)" != "0" ]; then
    echo "This script must be run as root." >&2
    exit 1
  fi

  # Do the initial apt-get update
  echo "Initial apt-get update..."
  apt-get update >/dev/null

  # Install wget if we have to (some older Ubuntu versions)
  echo "Installing wget..."
  apt-get install -y wget >/dev/null

  # Install the PuppetLabs repo
  echo "Configuring PuppetLabs repo..."
  repo_deb_path=$(mktemp)
  wget --output-document="${repo_deb_path}" "${REPO_DEB_URL}" 2>/dev/null
  dpkg -i "${repo_deb_path}" >/dev/null
  apt-get update >/dev/null

  # Install Puppet
  echo "Installing Puppet..."
  apt-get install -y puppet >/dev/null

  echo "Puppet installed!"

  # Install RubyGems for the provider
  echo "Installing RubyGems..."
  apt-get install -y rubygems >/dev/null
  gem install --no-ri --no-rdoc rubygems-update
  update_rubygems >/dev/null
}

if which puppet > /dev/null 2>&1; then
  echo "Puppet is already installed."
elif which pacman > /dev/null 2>&1; then
  bootstrap_arch
elif [ -f /etc/redhat-release ] && which rpm > /dev/null 2>&1 && which yum > /dev/null 2>&1;  then
  read OS_FAMILY ignore_2 OS_VERSION ignore_rest < /etc/redhat-release
  case "$OS_FAMILY" in
  Fedora)
    bootstrap_fedora
    ;;
  CentOS)
    bootstrap_centos_6_x
    ;;
  *)
    echo "Unknown redhat distribution ($OS_FAMILY)"
    ;;
  esac
  # how do we differentiate?
  #bootstrap_centos_5_x
elif which dpkg > /dev/null 2>&1 && which apt-get > /dev/null 2>&1; then
  is_ubunutu=`grep -isc '^id=ubuntu' /etc/os-release`
  if [ "$is_ubuntu" = 1 ]; then
    bootstrap_ubuntu
  else
    bootstrap_debian
  fi
else
  echo 'Unable to determine distribution!'
  exit 1
fi
puppet --version
