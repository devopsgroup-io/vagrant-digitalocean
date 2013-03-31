#!/bin/bash

if ! grep tester /etc/passwd; then
    useradd -m -s /bin/bash tester
fi

if ! grep tester /etc/sudoers; then
    echo "tester ALL=(ALL:ALL) NOPASSWD: ALL" >> /etc/sudoers
fi

mkdir -p /home/tester/.ssh
chown tester:tester /home/tester/.ssh

pub_key="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCbFlHJ++BcXGU9b2K+jF990r16uqkKnWiK2CFS0PFvM9IJs3CoGiIlyc9UD9O4LEyeu5Rw0RdiAp9MvyUPcDUeibw3WlMCFJ53mbioAapMy5tPXmxxJH5KcN2uJKESsH/1hJv0tWfVpHQywVLcf/7HWPjDl3qEFqzwGEN+5V3XqyG+hoA4rLTLDL40G68bL/oC7ere3sz3B16U4NGdgtJZapot5gTFErFZZztql76h25Ch7isE1XAaYg6NY4z1oU8Q9Ud0sY74tDI8TF165LStb3prf1TinwaMbOyuQ1wrNU4aMzekiwazeo6LtHMnfPjweIGP01PwjZ8WkYcRF6tt digital_ocean provider test key"

if ! [ -e /home/tester/.ssh/authorized_keys ]; then
    echo "${pub_key}" > /home/tester/.ssh/authorized_keys
fi
