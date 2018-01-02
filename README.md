DigitalOcean Vagrant Provider
==============================

[![Gem](https://img.shields.io/gem/v/vagrant-digitalocean.svg)](https://rubygems.org/gems/vagrant-digitalocean)
[![Gem](https://img.shields.io/gem/dt/vagrant-digitalocean.svg)](https://rubygems.org/gems/vagrant-digitalocean)
[![Gem](https://img.shields.io/gem/dtv/vagrant-digitalocean.svg)](https://rubygems.org/gems/vagrant-digitalocean)
[![Twitter](https://img.shields.io/twitter/url/https/github.com/devopsgroup-io/vagrant-digitalocean.svg?style=social)](https://twitter.com/intent/tweet?text=Check%20out%20this%20awesome%20Vagrant%20plugin%21&url=https%3A%2F%2Fgithub.com%2Fdevopsgroup-io%2Fvagrant-digitalocean&hashtags=vagrant%2Cdigitalocean&original_referer=)

`vagrant-digitalocean` is a Vagrant provider plugin that supports the management of [DigitalOcean](https://www.digitalocean.com/) Droplets (virtual machines).

Features include:
- Create and destroy Droplets
- Power on and off Droplets
- Rebuild a Droplet (destroys and ups with same IP address)
- Provision a Droplet with shell
- Setup a SSH public key for authentication
- Create a new user account during Droplet creation


Install
-------
Install the provider plugin using the Vagrant command-line interface:

`vagrant plugin install vagrant-digitalocean`


Configure
---------
Once the provider has been installed, you will need to configure your project to use it. See the following example for a basic multi-machine `Vagrantfile` implementation that manages two DigitalOcean Droplets:

```ruby
Vagrant.configure('2') do |config|

  config.vm.define "droplet1" do |config|
      config.vm.provider :digital_ocean do |provider, override|
        override.ssh.private_key_path = '~/.ssh/id_rsa'
        override.vm.box = 'digital_ocean'
        override.vm.box_url = "https://github.com/devopsgroup-io/vagrant-digitalocean/raw/master/box/digital_ocean.box"
        override.nfs.functional = false
        provider.token = 'YOUR TOKEN'
        provider.image = 'ubuntu-14-04-x64'
        provider.region = 'nyc1'
        provider.size = '512mb'
      end
  end

  config.vm.define "droplet2" do |config|
      config.vm.provider :digital_ocean do |provider, override|
        override.ssh.private_key_path = '~/.ssh/id_rsa'
        override.vm.box = 'digital_ocean'
        override.vm.box_url = "https://github.com/devopsgroup-io/vagrant-digitalocean/raw/master/box/digital_ocean.box"
        override.nfs.functional = false
        provider.token = 'YOUR TOKEN'
        provider.image = 'ubuntu-14-04-x64'
        provider.region = 'nyc3'
        provider.size = '1gb'
      end
  end

end
```

**Configuration Requirements**
- You *must* specify the `override.ssh.private_key_path` to enable authentication with the Droplet. The provider will create a new DigitalOcean SSH key using your public key which is assumed to be the `private_key_path` with a *.pub* extension.
- You *must* specify your DigitalOcean Personal Access Token at `provider.token`. This may be found on the control panel within the *Apps &amp; API* section.

**Supported Configuration Attributes**

The following attributes are available to further configure the provider:
- `provider.image`
    * A string representing the image to use when creating a new Droplet. It defaults to `ubuntu-14-04-x64`.
    List available images with the `vagrant digitalocean-list images $DIGITAL_OCEAN_TOKEN` command. Like when using the DigitalOcean API directly, [it can be an image ID or slug](https://developers.digitalocean.com/documentation/v2/#create-a-new-droplet).
- `provider.ipv6`
    * A boolean flag indicating whether to enable IPv6
- `provider.region`
    * A string representing the region to create the new Droplet in. It defaults to `nyc2`. List available regions with the `vagrant digitalocean-list regions $DIGITAL_OCEAN_TOKEN` command.
- `provider.size`
    * A string representing the size to use when creating a new Droplet (e.g. `1gb`). It defaults to `512mb`. List available sizes with the `vagrant digitalocean-list sizes $DIGITAL_OCEAN_TOKEN` command.
- `provider.private_networking`
    * A boolean flag indicating whether to enable a private network interface (if the region supports private networking). It defaults to `false`.
- `provider.backups_enabled`
    * A boolean flag indicating whether to enable backups for the Droplet. It defaults to `false`.
- `provider.ssh_key_name`
    * A string representing the name to use when creating a DigitalOcean SSH key for Droplet authentication. It defaults to `Vagrant`.
- `provider.setup`
    * A boolean flag indicating whether to setup a new user account and modify sudo to disable tty requirement. It defaults to `true`. If you are using a tool like [Packer](https://packer.io) to create reusable snapshots with user accounts already provisioned, set to `false`.
- `provider.monitoring`
    * A boolean indicating whether to install the DigitalOcean agent for monitoring. It defaults to `false`.
- `provider.tags`
    * A flat array of tag names as strings to apply to the Droplet after it is created. Tag names can either be existing or new tags.
- `provider.volumes`
    * A flat array including the unique identifier for each Block Storage volume attached to the Droplet.
- `config.vm.synced_folder`
    * Supports both rsync__args and rsync__exclude, see the [Vagrant Docs](http://docs.vagrantup.com/v2/synced-folders/rsync.html) for more information. rsync__args default to `["--verbose", "--archive", "--delete", "-z", "--copy-links"]` and rsync__exclude defaults to `[".vagrant/"]`.

The provider will create a new user account with the specified SSH key for authorization if `config.ssh.username` is set and the `provider.setup` attribute is `true`.


Run
---
After creating your project's `Vagrantfile` with the required configuration
attributes described above, you may create a new Droplet with the following
command:

    $ vagrant up --provider=digital_ocean

This command will create a new Droplet, setup your SSH key for authentication,
create a new user account, and run the provisioners you have configured.

**Supported Commands**

The provider supports the following Vagrant sub-commands:
- `vagrant destroy` - Destroys the Droplet instance.
- `vagrant ssh` - Logs into the Droplet instance using the configured user account.
- `vagrant halt` - Powers off the Droplet instance.
- `vagrant provision` - Runs the configured provisioners and rsyncs any specified `config.vm.synced_folder`.
- `vagrant reload` - Reboots the Droplet instance.
- `vagrant rebuild` - Destroys the Droplet instance and recreates it with the same IP address which was previously assigned.
- `vagrant status` - Outputs the status (active, off, not created) for the Droplet instance.

Compatibility
-------------
This [DigitalOcean API](https://developers.digitalocean.com/documentation/changelog/) provider plugin for Vagrant has been tested with the following technology.

Date Tested | Vagrant Version | vagrant-digitalocean Version | Host (Workstation) Operating System | Guest (DigitalOcean) Operating System
------------|-----------------|------------------------------|-----------------------|--------------------------------------
03/22/2016  | 1.8.1           | 0.7.10                       | OS X 10.11.4          | CentOS 7.0
04/03/2013  | 1.1.5           | 0.1.0                        | Ubuntu 12.04          | CentOS 6.3


Troubleshooting
---------------
Before submitting a GitHub issue, please ensure both Vagrant and vagrant-digitalocean are fully up-to-date.
* For the latest Vagrant version, please visit the [Vagrant](https://www.vagrantup.com/) website
* To update Vagrant plugins, run the following command: `vagrant plugin update`

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
3. Then install vagrant-digitalocean dependencies:
    * `bundle _1.7.9_ install`
4. Do your development and run a few commands, one to get started would be:
    * `bundle _1.7.9_ exec vagrant digitalocean-list images`
5. You can then run a test:
    * `bundle _1.7.9_ exec rake test`
6. Once you are satisfied with your changes, please submit a pull request.

**Testing**

1. Build and package your newly developed code:
    * `rake gem:build`
2. Then install the packaged plugin:
    * `vagrant plugin install pkg/vagrant-digitalocean-*.gem`
3. Once you're done testing, roll-back to the latest released version:
    * `vagrant plugin uninstall vagrant-digitalocean`
    * `vagrant plugin install vagrant-digitalocean`
4. Once you're satisfied developing and testing your new code, please submit a pull request for review.

**Releasing**

To release a new version of vagrant-digitalocean you will need to do the following:

*(only contributors of the GitHub repo and owners of the project at RubyGems will have rights to do this)*

1. First, bump the version in ~/lib/vagrant-digitalocean/version.rb:
    * Follow [Semantic Versioning](http://semver.org/).
2. Then, create a matching GitHub Release (this will also create a tag):
    * Preface the version number with a `v`.
    * https://github.com/devopsgroup-io/vagrant-digitalocean/releases
3. You will then need to build and push the new gem to RubyGems:
    * `rake gem:build`
    * `gem push pkg/vagrant-digitalocean-0.7.6.gem`
4. Then, when John Doe runs the following, they will receive the updated vagrant-digitalocean plugin:
    * `vagrant plugin update`
    * `vagrant plugin update vagrant-digitalocean`
