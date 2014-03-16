#!/bin/bash

echo 'Testing 1 2 3 with shell provisioner!'
umask 0
mkdir -p /tmp/folder
chmod a+rwx /tmp/folder
date > /tmp/folder/file_from_shell
