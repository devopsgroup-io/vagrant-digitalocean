DigitalOcean Vagrant Provider
==============================

[![Gem](https://img.shields.io/gem/dt/vagrant-digitalocean.svg)](https://rubygems.org/gems/vagrant-digitalocean)
[![Gem](https://img.shields.io/gem/dtv/vagrant-digitalocean.svg)](https://rubygems.org/gems/vagrant-digitalocean)
[![Twitter](https://img.shields.io/twitter/url/https/github.com/smdahlen/vagrant-digitalocean.svg?style=social)](https://twitter.com/intent/tweet?text=Check%20out%20this%20awesome%20Vagrant%20plugin%21&url=https%3A%2F%2Fgithub.com%2Fsmdahlen%2Fvagrant-digitalocean&hashtags=vagrant%2Cdigitalocean&original_referer=)

`vagrant-digitalocean` is a provider plugin for Vagrant that supports the management of [DigitalOcean](https://www.digitalocean.com/) droplets (instances).

Features include:
- create and destroy droplets
- power on and off droplets
- rebuild a droplet (destroys and ups with same IP address)
- provision a droplet with shell
- setup a SSH public key for authentication
- create a new user account during droplet creation

The provider has been tested with Vagrant 1.1.5+ using Ubuntu 12.04 and CentOS 6.3 guest operating systems.


Install
-------
Install the provider plugin using the Vagrant command-line interface:

`vagrant plugin install vagrant-digitalocean`


Configure
---------
Once the provider has been installed, you will need to configure your project to use it. The most basic `Vagrantfile` to create a droplet on DigitalOcean is shown below:

```ruby
Vagrant.configure('2') do |config|

  # name for your droplet; visible in DO control panel
  config.vm.hostname = 'vagrant_droplet'

  config.vm.provider :digital_ocean do |provider, override|
    override.ssh.private_key_path = '~/.ssh/id_rsa'
    override.vm.box = 'digital_ocean'
    override.vm.box_url = "https://github.com/smdahlen/vagrant-digitalocean/raw/master/box/digital_ocean.box"

    provider.token = 'YOUR TOKEN'
    provider.image = 'ubuntu-14-04-x64'
    provider.region = 'nyc2'
    provider.size = '512mb'
  end
end
```

**Configuration Requirements**
- You *must* specify the `override.ssh.private_key_path` to enable authentication with the droplet. The provider will create a new DigitalOcean SSH key using your public key which is assumed to be the `private_key_path` with a *.pub* extension.
- You *must* specify your DigitalOcean Personal Access Token at `provider.token`. This may be found on the control panel within the *Apps &amp; API* section.
- To specify a name for your droplet, specify the `config.vm.hostname` property as documented in the [Vagrant documentation](https://docs.vagrantup.com/v2/vagrantfile/machine_settings.html); this will be used in your DigitalOcean control panel. Falls back to "*default*".

**Supported Configuration Attributes**

The following attributes are available to further configure the provider:
- `provider.image`
    * A string representing the image to use when creating a new droplet. It defaults to `ubuntu-14-04-x64`.
    List available images with the `vagrant digitalocean-list images $DIGITAL_OCEAN_TOKEN` command. Like when using the DigitalOcean API directly, [it can be an image ID or slug](https://developers.digitalocean.com/documentation/v2/#create-a-new-droplet).
- `provider.ipv6`
    * A boolean flag indicating whether to enable IPv6
- `provider.region`
    * A string representing the region to create the new droplet in. It defaults to `nyc2`. List available regions with the `vagrant digitalocean-list regions $DIGITAL_OCEAN_TOKEN` command.
- `provider.size`
    * A string representing the size to use when creating a new droplet (e.g. `1gb`). It defaults to `512mb`. List available sizes with the `vagrant digitalocean-list sizes $DIGITAL_OCEAN_TOKEN` command.
- `provider.private_networking`
    * A boolean flag indicating whether to enable a private network interface (if the region supports private networking). It defaults to `false`.
- `provider.backups_enabled`
    * A boolean flag indicating whether to enable backups for the droplet. It defaults to `false`.
- `provider.ssh_key_name`
    * A string representing the name to use when creating a DigitalOcean SSH key for droplet authentication. It defaults to `Vagrant`.
- `provider.setup`
    * A boolean flag indicating whether to setup a new user account and modify sudo to disable tty requirement. It defaults to `true`. If you are using a tool like [Packer](https://packer.io) to create reusable snapshots with user accounts already provisioned, set to `false`.
- `config.vm.synced_folder`
    * Supports both rsync__args and rsync__exclude, see the [Vagrant Docs](http://docs.vagrantup.com/v2/synced-folders/rsync.html) for more information. rsync__args default to `["--verbose", "--archive", "--delete", "-z", "--copy-links"]` and rsync__exclude defaults to `[".vagrant/"]`.

The provider will create a new user account with the specified SSH key for authorization if `config.ssh.username` is set and the `provider.setup` attribute is `true`.


Run
---
After creating your project's `Vagrantfile` with the required configuration
attributes described above, you may create a new droplet with the following
command:

    $ vagrant up --provider=digital_ocean

This command will create a new droplet, setup your SSH key for authentication,
create a new user account, and run the provisioners you have configured.

**Supported Commands**

The provider supports the following Vagrant sub-commands:
- `vagrant destroy` - Destroys the droplet instance.
- `vagrant ssh` - Logs into the droplet instance using the configured user account.
- `vagrant halt` - Powers off the droplet instance.
- `vagrant provision` - Runs the configured provisioners and rsyncs any specified `config.vm.synced_folder`.
- `vagrant reload` - Reboots the droplet instance.
- `vagrant rebuild` - Destroys the droplet instance and recreates it with the same IP address which was previously assigned.
- `vagrant status` - Outputs the status (active, off, not created) for the droplet instance.


Troubleshooting
---------------

* `vagrant plugin install vagrant-digitalocean` 
    * Installation on OS X may not working due to a SSL certificate problem, and you may need to specify a certificate path explicitly. To do so, run `ruby -ropenssl -e "p OpenSSL::X509::DEFAULT_CERT_FILE"`. Then, add the following environment variable to your `.bash_profile` script and `source` it: `export SSL_CERT_FILE=/usr/local/etc/openssl/cert.pem`.


FAQ
---

* The Chef provisioner is no longer supported by default (as of 0.2.0). Please use the `vagrant-omnibus` plugin to install Chef on Vagrant-managed machines. This plugin provides control over the specific version of Chef to install.


Contribute
----------
To contribute, fork then clone the repository, and then the following:

**Developing**

1. Install [Bundler](http://bundler.io/)
2. Currently the Bundler version is locked to 1.7.9, please install this version.
    * `sudo gem install bundler -v '1.7.9'`
3. Then install vagrant-digitalocean dependancies:
    * `bundle _1.7.9_ install`
4. Do your development and run a few commands, one to get started would be:
    * `bundle _1.7.9_ exec vagrant digitalocean-list images`
5. You can then run a test:
    * `bundle _1.7.9_ exec rake test`
6. Once you are satisfied with your changes, please submit a pull request.

**Releasing**

To release a new version of vagrant-digitalocean you will need to do the following:

*(only contributors of the GitHub repo and owners of the project at RubyGems will have rights to do this)*

1. First, bump the version in ~/lib/vagrant-digitalocean/version.rb:
    * Follow [Semantic Versioning](http://semver.org/).
2. Then, create a matching GitHub Release (this will also create a tag):
    * Preface the version number with a `v`.
    * https://github.com/smdahlen/vagrant-digitalocean/releases
3. You will then need to build and push the new gem to RubyGems:
    * `rake gem:build`
    * `gem push pkg/vagrant-digitalocean-0.7.6.gem`
4. Then, when John Doe runs the following, they will receive the updated vagrant-digitalocean plugin:
    * `vagrant plugin update`
    * `vagrant plugin update vagrant-digitalocean`
