# fix the default sudoers file to prevent the tty requirement
sed -i'.bk' -e 's/\(Defaults\s\+requiretty\)/# \1/' /etc/sudoers
