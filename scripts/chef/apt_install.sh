# exit if it's already installed
if (which chef-solo); then exit 0; fi;

# update the repo to make sure that the package is available from the repo
apt-get update;

# avoid server url popup
echo "chef chef/chef_server_url string https://api.opscode.com/organizations/vagrant" | debconf-set-selections && apt-get install chef -y;
