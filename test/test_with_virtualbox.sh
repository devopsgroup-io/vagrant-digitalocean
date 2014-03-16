#!/bin/bash

export PROVIDER=${PROVIDER:-virtualbox}

cd test
set -xe

has_vbguest=`vagrant plugin list | grep vagrant-vbguest`
env DISTRIBUTIONS=arch EXCLUDE=chef bash test.sh
env DISTRIBUTIONS=centos bash test.sh
env DISTRIBUTIONS=debian bash test.sh
env DISTRIBUTIONS=fedora INSTALL_RSYNC=true "RELOAD_BEFORE_PROVISION=$has_vbguest" bash test.sh
env DISTRIBUTIONS=ubuntu32 bash test.sh
env DISTRIBUTIONS=ubuntu bash test.sh

cd ..

