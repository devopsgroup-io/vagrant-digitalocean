# Insecure Keypair

These keys are identical to those in the Vagrant source tree. You can configure the Digital Ocean provider to use a specific public key. Eg:

```Ruby
Vagrant.configure("2") do |config|
  config.vm.box = "digital_ocean"

  config.vm.provider :digital_ocean do |vm|
    vm.public_key_path = "path/to/public/key.pub"
    vm.ssh_key_name = "Foo"
  end
end
```

Note that you must specificy the `ssh_key_name` if you wish use your own private key.
