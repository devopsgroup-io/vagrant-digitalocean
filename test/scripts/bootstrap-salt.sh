#!/bin/sh -

# We just download the bootstrap script by default and execute that.

read_url()
{
  if which python > /dev/null 2>&1; then
    python -c "import urllib; print urllib.urlopen('$1').read()"
  elif which curl > /dev/null 2>&1; then
    curl --fail --location --silent "$1" 
  elif which wget > /dev/null 2>&1; then
    wget --quiet -O - "$1"
  else
    echo "Error need python or curl or wget to read a url $1" 
    exit 2
  fi
}

(
  echo Trying standard salt bootstrap ...
  ( 
    read_url "http://bootstrap.saltstack.org" |
    sh -s -- "$@") && which salt-call && which salt-minion
) || (
  echo Trying salt bootstrap: stable ...
  ( 
    read_url "https://raw.github.com/saltstack/salt-bootstrap/stable/bootstrap-salt.sh" |
     sh -s -- "$@") && which salt-call && which salt-minion
) || (
  echo Trying salt bootstrap: v2014.02.27 ...
  ( 
    read_url "https://raw.github.com/saltstack/salt-bootstrap/v2014.02.27/bootstrap-salt.sh" |
     sh -s -- "$@") && which salt-call && which salt-minion
) || (
  echo Trying salt bootstrap: v2014.02.19 ...
  ( 
    read_url "https://raw.github.com/saltstack/salt-bootstrap/v2014.02.19/bootstrap-salt.sh" |
     sh -s -- "$@") && which salt-call && which salt-minion
) || (
  echo Trying salt bootstrap: v2014.02.18 ...
  ( 
    read_url "https://raw.github.com/saltstack/salt-bootstrap/v2014.02.18/bootstrap-salt.sh" |
     sh -s -- "$@") && which salt-call && which salt-minion
) || (
  echo Trying salt bootstrap: v2014.02.16 ...
  ( 
    read_url "https://raw.github.com/saltstack/salt-bootstrap/v2014.02.16/bootstrap-salt.sh" |
     sh -s -- "$@") && which salt-call && which salt-minion
) || (
  echo Trying salt bootstrap: 1.5.11 ...
  ( 
    read_url "https://raw.github.com/saltstack/salt-bootstrap/v1.5.11/bootstrap-salt.sh" |
     sh -s -- "$@") && which salt-call && which salt-minion
) || ( 
  echo Failed to bootstrap salt! 
  exit 1 
)
salt-call --version
