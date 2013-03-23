# Vagrant Digital Ocean

`vagrant-digitalocean` is a provider plugin for Vagrant that allows the management of [Digital Ocean](https://www.digitalocean.com/) droplets (instances).

## SSH Key Support

By default the provider will use the *insecure* vagrant key for SSH access. That means anyone with the vagrant key and the IP of your droplet has root on your machine. To ovvrride this behavior, define your SSH key name and public key path within the provider configuration:

```ruby
    config.vm.provider :digital_ocean do |provider|
        provider.ssh_key_name = "My Laptop"
        provider.pub_ssh_key_path = "~/.ssh/id_rsa.pub"

        # additional configuration here
    end
```

The provider will assume the private key path is identical to the public key path without the *.pub* extention. If this is not the case, define the private key path using `config.ssh.private_key_path`. If an SSH key name is not set, it will default to *Vagrant*.

## Status

As of this writing the provider implementation is geared entirely toward a development workflow. That is, Digital Ocean droplets are meant to be used as a replacement for VirtualBox in a server developers workflow.

## Supported Guests/Hosts

This project is primarily to support my workflow which currently only involves Ubuntu and CentOS. It's likely that any unix host will work but I've not tested it. Guests require porting of the nfs, chef, and sudo setup scripts.

Hosts:

* Ubuntu 12.04

Guests:

* Ubuntu 12.04
* CentOS 6

## Supported Provisioners

The shell provisioner is supported by default but other provisioners require bootstrapping on the server. Chef is currently the only supported provisioner. Adding support for puppet and others requires adding the install scripts.

## Installation

Installation is performed in the prescribed manner for Vagrant 1.1 plugins.

    vagrant plugin install vagrant-digitalocean

In addition to installing the plugin the default box associated with the provider needs to be installed.

    vagrant box add digital_ocean https://raw.github.com/johnbender/vagrant-digitalocean/master/box/digital_ocean.box

## Usage

To use the Digital Ocean provider you will need to visit the [API access page](https://www.digitalocean.com/api_access) to retrieve the client identifier and API key associated with your account.

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
    vm.ssh_key_name = "My Key"
    vm.pub_ssh_key_path = "~/.ssh/id_rsa"

    # optional config for SSL cert on OSX and others
    vm.ca_path = "/usr/local/etc/openssl/ca-bundle.crt"
  end
end
```

Note that the example contains the default value. The client identifier and API key are pulled from the environment and the other values are the string representations of the droplet configuration options as provided by the [Digital Ocean API](https://www.digitalocean.com/api). The ca_path configuration option may be necessary depending on your system setup.

## Tests

Testing is very simple initially. There is no guaranteed cleanup. That is, if you are testing using `rake test` **you** are responsible for making sure that there aren't large numbers of test machines left on your Digital Ocean account.

```bash
rake test # and wait ...
```

Cleanup will be added eventually but will have to be specified explicitly because of the risk of machine deletetion.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
