# if ! vagrant box list | grep digital_ocean 1>/dev/null; then
#     vagrant box add digital_ocean box/digital_ocean.box
# fi

cd test

vagrant up --provider=digital_ocean
vagrant up
vagrant provision
vagrant rebuild
vagrant halt
vagrant destroy

cd ..
