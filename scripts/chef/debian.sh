# skip if chef-solo is present
if (which chef-solo); then exit 0; fi

# download and run the omnibus installer
wget -O - http://www.opscode.com/chef/install.sh | bash
