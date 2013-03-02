require "vagrant-digitalocean/action_dispatch"

module VagrantPlugins
  module DigitalOcean
    class Provider < Vagrant.plugin("2", :provider)
      # Initialize the provider to represent the given machine.
      #
      # @param [Vagrant::Machine] machine The machine that this provider
      #   is responsible for.
      def initialize(machine)
        @machine = machine
        @dispatch = ActionDispatch.new
      end

      # This should return an action callable for the given name.
      #
      # @param [Symbol] name Name of the action.
      # @return [Object] A callable action sequence object, whether it
      #   is a proc, object, etc.
      def action(name)
        return @dispatch.action(name) if @dispatch.respond_to?(name)
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
      #
      # @return [Hash] SSH information. For the structure of this hash
      #   read the accompanying documentation for this method.
      def ssh_info
        state = @machine.action("read_state")[:machine_state]

        return nil if state["status"] == :not_created

        # If the machine was just created (eg, this is an up) and
        # the machine user hasn't been created use root. Otherwise
        # set the username to the user (most likely vagrant)
        #
        # TODO use a config option for alternate users
        username = state[:just_created] && !state[:user] ? "root" : "vagrant"
        username = "root"

        return {
          :host => state["ip_address"],
          :port => "22",
          # if the SetupVagrantUser action has run the machine
          # state will contain a user
          :username => username,
          :private_key_path => Vagrant.source_root + "keys/vagrant"
        }
      end

      # This should return the state of the machine within this provider.
      # The state must be an instance of {MachineState}. Please read the
      # documentation of that class for more information.
      #
      # @return [MachineState]
      def state
        state_id = @machine.action("read_state")[:machine_state]["status"].to_sym

        # TODO provide an actual description
        long = short = state_id.to_s

        # Return the MachineState object
        Vagrant::MachineState.new(state_id, short, long)
      end
    end
  end
end
