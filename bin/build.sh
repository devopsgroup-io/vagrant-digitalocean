# build the gem
gem build *.gemspec

# make the gem available for installation as a vagrant plugin
gem install *.gem

# make sure bsdtar is installed
if ! `which bsdtar > /dev/null`; then
  echo "!! Install bsdtar"
  exit 1
fi

# install the plugin
vagrant plugin install vagrant-digitalocean

# move into the dummy box dir
cd box

# create the dummy box
tar cvzf digital_ocean.box ./metadata.json

# remove an old version of the dummy box
if `vagrant box list | grep -q digital_ocean`; then
  vagrant box remove digital_ocean digital_ocean
fi

# add the new version of the dummy box
vagrant box add digital_ocean digital_ocean.box

# back out of the box dir
cd -
