# install the nfs-kernel server
if !(which nfsstat); then
  apt-get install -y nfs-kernel-server;
fi
