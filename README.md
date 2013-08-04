Digital Ocean Vagrant Provider
==============================
`vagrant-digitalocean` is a provider plugin for Vagrant that supports the
management of [Digital Ocean](https://www.digitalocean.com/) droplets
(instances).

**NOTE:** The Chef provisioner is no longer supported by default (as of 0.2.0).
Please use the `vagrant-omnibus` plugin to install Chef on Vagrant-managed
machines. This plugin provides control over the specific version of Chef
to install. The custom `rebuild` command will not work until a
[pull request](https://github.com/schisamo/vagrant-omnibus/pull/21)
is accepted within the `vagrant-omnibus` project. I will update the README
when this is completed.

Current features include:
- create and destroy droplets
- power on and off droplets
- rebuild a droplet
- provision a droplet with the shell or Chef provisioners
- setup a SSH public key for authentication
- create a new user account during droplet creation

The provider has been tested with Vagrant 1.1.5 using Ubuntu 12.04 and
CentOS 6.3 guest operating systems.

Install
-------
Installation of the provider requires two steps:

1. Install the provider plugin using the Vagrant command-line interface:

        $ vagrant plugin install vagrant-digitalocean


**NOTE:** If you are using a Mac, you may need to install a CA bundle to enable SSL
communication with the Digital Ocean API. It is recommended to first install
[Homebrew](http://mxcl.github.io/homebrew/). With Homebrew installed, run
the following command to install the bundle:

    $ brew install curl-ca-bundle

Once the bundle is installed, add the following environment variable to your
`.bash_profile` script and `source` it:

```bash
export SSL_CERT_FILE=/usr/local/opt/curl-ca-bundle/share/ca-bundle.crt
```

Configure
---------
Once the provider has been installed, you will need to configure your project
to use it. The most basic `Vagrantfile` to create a droplet on Digital Ocean
is shown below:

```ruby
Vagrant.configure('2') do |config|

  config.vm.provider :digital_ocean do |provider, override|
    override.ssh.private_key_path = '~/.ssh/id_rsa'
    override.vm.box = 'digital_ocean'
    override.vm.box_url = "https://github.com/smdahlen/vagrant-digitalocean/raw/master/box/digital_ocean.box"
    
    provider.client_id = 'YOUR CLIENT ID'
    provider.api_key = 'YOUR API KEY'
  end
end
```

Please note the following:
- You *must* specify the `config.ssh.private_key_path` to enable authentication
  with the droplet. The provider will create a new Digital Ocean SSH key using
  your public key which is assumed to be the `private_key_path` with a *.pub*
  extension.
- You *must* specify your Digital Ocean Client and API keys. These may be
  found on the control panel within the *My Settings > API Access* section.
- The Chef provisioner is installed via the
  [`vagrant-omnibus` plugin](https://github.com/schisamo/vagrant-omnibus).
  Please see its documentation for details. 

**Supported Configuration Attributes**

The following attributes are available to further configure the provider:
- `provider.image` - A string representing the image to use when creating a
   new droplet (e.g. `Debian 6.0 x64`). The available options may
   be found on Digital Ocean's new droplet [form](https://www.digitalocean.com/droplets/new).
   It defaults to `Ubuntu 12.04 x64 Server`.
- `provider.region` - A string representing the region to create the new
   droplet in. The available options are `New York 1` and `Amsterdam 1`. It
   defaults to `New York 1`.
- `provider.size` - A string representing the size to use when creating a
  new droplet (e.g. `1GB`). It defaults to `512MB`.
- `provider.ssh_key_name` - A String representing the name to use when creating
  a Digital Ocean SSH key for droplet authentication. It defaults to `Vagrant`.

By default, the provider will create a new user account, `vagrant`, and setup
the specified SSH key for authentication. To change the user, set
`config.ssh.username` to the name of the account to create. When Vagrant 1.2 is
released, a new user account will only be created if `config.ssh.username` is
set.

*NOTE:* For those using a 0.0.x version of the provider,
`provider.ssh_username` and `provider.ssh_private_key_path` have been removed
in favor of the configuration options above.

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
- `vagrant ssh` - Logs into the droplet instance using the configured user
  account.
- `vagrant halt` - Powers off the droplet instance.
- `vagrant provision` - Runs the configured provisioners and rsyncs any
  specified `config.vm.synced_folder`.
- `vagrant reload` - Reboots the droplet instance.
- `vagrant rebuild` - Destroys the droplet instance and recreates it with the
  same IP address is was assigned to previously.
- `vagrant status` - Outputs the status (active, off, not created) for the
  droplet instance.

Contribute
----------
To contribute, clone the repository, and use [Bundler](http://gembundler.com)
to install dependencies:

    $ bundle

To run the provider's tests:

    $ bundle exec rake test

You can now make modifications. Running `vagrant` within the Bundler
environment will ensure that plugins installed in your Vagrant
environment are not loaded.
