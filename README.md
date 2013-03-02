# Vagrant Digital Ocean

`vagrant-digitalocean` is a provider plugin for Vagrant that allows the management of [Digital Ocean](https://www.digitalocean.com/) droplets (instances).

## Status

As of this writing the provider implementation is geared entirely toward a development workflow. That is, Digital Ocean droplets are meant to be used as a replacement for VirtualBox in a server developers workflow.

## Tested Guests/Hosts

So far testing has been performed on an Ubuntu 12.04 host with the assumption of a Debian based guest. Currently the main limitation is the preparation of a vanilla droplet for NFS (which requires distro specific package installs/setup). It should be extremely simple to extend the guest support to accommodate other distributions.

## Installation

Installation is performed in the prescribed manner for Vagrant 1.1 plugins.

    vagrant plugin install vagrant-digitalocean

In addition to installing the plugin the default box associated with the provider needs to be installed.

    vagrant box add digital_ocean https://raw.github.com/johnbender/vagrant-digitalocean/master/box/digital_ocean.box

## Usage

To use the Digital Ocean provider you will need to visit the [API access page](https://www.digitalocean.com/api_access) to retrieve the client identifier and API key associated with your account.

### Commands

TODO

### Config

Supported provider configuration options are as follows:

```ruby
Vagrant.configure("2") do |config|
  config.vm.box = "digital_ocean"

  config.vm.provider :digital_ocean do |vm|
    vm.client_id = ENV["DO_CLIENT_ID"]
    vm.api_key = ENV["DO_API_KEY"]
    vm.image = "Ubuntu 12.04 x32 Server"
    vm.region = "New York 1"
    vm.size = "512MB"
  end
end
```

Note that the example contains the default value. The client identifier and API key are pulled from the environment and the other values are the string representations of the droplet configuration options as provided by the [Digital Ocean API](https://www.digitalocean.com/api).

## TODO

1. Provisioning (chef/puppet setup where necessary)
2. Suspend by taking a snapsot
3. Resume by restoring from snapshot
4. Reload reboot and provision
5. Permit custom ssh keys

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
