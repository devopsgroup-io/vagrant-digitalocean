if (service --status-all | grep nfs); then exit 0; fi;

# install the nfs-kernel server
yum install -y nfs-utils nfs-utils-lib;

# add to startup
chkconfig nfs on;

# make sure it's on after the install
service rpcbind start;
service nfs start;
