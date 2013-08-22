require 'vagrant-digitalocean/actions'

module VagrantPlugins
  module DigitalOcean
    class Provider < Vagrant.plugin('2', :provider)

      # This class method caches status for all droplets within
      # the Digital Ocean account. A specific droplet's status
      # may be refreshed by passing :refresh => true as an option.
      def self.droplet(machine, opts = {})
        client = Helpers::ApiClient.new(machine)

        # load status of droplets if it has not been done before
        if !@droplets
          result = client.request('/droplets')
          @droplets = result['droplets']
        end

        if opts[:refresh] && machine.id
          # refresh the droplet status for the given machine
          @droplets.delete_if { |d| d['id'].to_s == machine.id }
          result = client.request("/droplets/#{machine.id}")
          @droplets << droplet = result['droplet']
        else
          # lookup droplet status for the given machine
          droplet = @droplets.find { |d| d['id'].to_s == machine.id }
        end

        # if lookup by id failed, check for a droplet with a matching name
        # and set the id to ensure vagrant stores locally
        # TODO allow the user to configure this behavior
        if !droplet
          name = machine.config.vm.hostname || machine.name
          droplet = @droplets.find { |d| d['name'] == name.to_s }
          machine.id = droplet['id'].to_s if droplet
        end

        droplet ||= {'status' => 'not_created'}
      end

      def initialize(machine)
        @machine = machine
      end

      def action(name)
        return Actions.send(name) if Actions.respond_to?(name)
        nil
      end

      # This method is called if the underying machine ID changes. Providers
      # can use this method to load in new data for the actual backing
      # machine or to realize that the machine is now gone (the ID can
      # become `nil`). No parameters are given, since the underlying machine
      # is simply the machine instance given to this object. And no
      # return value is necessary.
      def machine_id_changed
      end

      # This should return a hash of information that explains how to
      # SSH into the machine. If the machine is not at a point where
      # SSH is even possible, then `nil` should be returned.
      #
      # The general structure of this returned hash should be the
      # following:
      #
      #     {
      #       :host => "1.2.3.4",
      #       :port => "22",
      #       :username => "mitchellh",
      #       :private_key_path => "/path/to/my/key"
      #     }
      #
      # **Note:** Vagrant only supports private key based authenticatonion,
      # mainly for the reason that there is no easy way to exec into an
      # `ssh` prompt with a password, whereas we can pass a private key
      # via commandline.
      def ssh_info
        droplet = Provider.droplet(@machine)

        return nil if droplet['status'].to_sym != :active

        return {
          :host => droplet['ip_address'],
          :port => '22',
          :username => 'root',
          :private_key_path => nil
        }
      end

      # This should return the state of the machine within this provider.
      # The state must be an instance of {MachineState}. Please read the
      # documentation of that class for more information.
      def state
        state = Provider.droplet(@machine)['status'].to_sym
        long = short = state.to_s
        Vagrant::MachineState.new(state, short, long)
      end
    end
  end
end
