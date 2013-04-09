# Vagrant Digital Ocean

`vagrant-digitalocean` is a provider plugin for Vagrant that allows the
management of [Digital Ocean](https://www.digitalocean.com/) droplets
(instances).

## SSH Authentication

This provider does not support the use of Vagrant's insecure key for SSH
access. You must specify your own SSH key. The key may be defined within
the global config section, `config.ssh.private_key_path`, or within the
provider config section, `provider.ssh_private_key_path`. The provider
config will take precedence. Additionally, you may provide a name for
the SSH key using the `ssh_key_name` attribute within the provider config
section. This is useful for de-conflict SSH keys used by different
individuals when creating machines on Digital Ocean.

```ruby
    config.vm.provider :digital_ocean do |provider|
        provider.ssh_key_name = "My Laptop"
        provider.ssh_private_key_path = "~/.ssh/id_rsa"

        # additional configuration here
    end
```

The provider will assume the public key path is identical to the private
key path with the *.pub* extention.

By default, the provider uses the `root` account for SSH access. This is
required for initial droplet creation and provisioning. You may specify
an account that may be used for subsequent SSH access and provisioning
by setting the `ssh_username` attribute within the provider config
section.

## Supported Guests/Hosts

The project is currently in alpha state and has been tested on the
following hosts and guests:

Hosts:

* Ubuntu 12.04
* Mac OS X

Guests:

* Ubuntu 12.04
* CentOS 6

## Supported Provisioners

The shell provisioner is supported by default but other provisioners require
bootstrapping on the server. Chef is currently the only supported provisioner.
Adding support for puppet and others requires adding the install scripts.

## Installation

Installation is performed in the prescribed manner for Vagrant 1.1 plugins.

    vagrant plugin install vagrant-digitalocean

In addition to installing the plugin the default box associated with the
provider needs to be installed.

    vagrant box add digital_ocean https://raw.github.com/smdahlen/vagrant-digitalocean/master/box/digital_ocean.box

## Usage

To use the Digital Ocean provider you will need to visit the
[API access page](https://www.digitalocean.com/api_access) to retrieve
the client identifier and API key associated with your account.

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
    vm.ssh_private_key_path = "~/.ssh/id_rsa"
    vm.ssh_username = "test"

    # optional config for SSL cert on OSX and others
    vm.ca_path = "/usr/local/etc/openssl/ca-bundle.crt"
  end
end
```

Note that the example contains the default value. The client identifier and
API key are pulled from the environment and the other values are the string
representations of the droplet configuration options as provided by the
[Digital Ocean API](https://www.digitalocean.com/api). The ca_path
configuration option may be necessary depending on your system setup.

## Development

To contribute, clone the repository, and use [Bundler](http://gembundler.com)
to install dependencies:

    $ bundle

To run the provider's tests:

    $ bundle exec rake test

You can now make modifications. Running `vagrant` within the Bundler
environment will ensure that plugins installed in your Vagrant
environment are not loaded.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
