function run_test_for {
  cp Vagrantfile.$1 Vagrantfile
  vagrant up --provider=digital_ocean
  vagrant up
  vagrant provision
  vagrant rebuild
  vagrant destroy
  vagrant destroy
}

set -e

# make sure bsdtar is installed
if ! `which bsdtar > /dev/null`; then
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

run_test_for centos
run_test_for ubuntu
