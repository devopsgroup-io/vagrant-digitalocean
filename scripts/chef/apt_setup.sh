if [-e /etc/apt/sources.list.d/opscode.list]; then exit 0; fi;
# install the basics
apt-get install -y wget lsb-release;

# add the opscode repo to the sources
echo "deb http://apt.opscode.com/ `lsb_release -cs`-0.10 main" | sudo tee /etc/apt/sources.list.d/opscode.list;

# setup the gpg key
mkdir -p /etc/apt/trusted.gpg.d;
gpg --keyserver keys.gnupg.net --recv-keys 83EF826A;
gpg --export packages@opscode.com | sudo tee /etc/apt/trusted.gpg.d/opscode-keyring.gpg > /dev/null;
