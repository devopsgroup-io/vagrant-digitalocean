set -e

# make sure bsdtar is installed
if ! (which bsdtar > /dev/null); then
  echo "!! Install bsdtar"
  exit 1
fi

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

cd ../test

vagrant up --provider=digital_ocean
vagrant up
vagrant provision
vagrant rebuild
vagrant halt
vagrant destroy
