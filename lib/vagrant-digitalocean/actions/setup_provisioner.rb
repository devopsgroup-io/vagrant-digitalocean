require "vagrant-digitalocean/helpers/file"

module VagrantPlugins
  module DigitalOcean
    module Actions
      class SetupProvisioner
        include Helpers::File

        def initialize(app, env)
          @app, @env = app, env
          @translator = Helpers::Translator.new("actions.setup_provisioner")
        end

        def call(env)
          # TODO prevent setup when no chef provisioner declared
          # TODO catch ssh failure and report back on install issues
          # TODO first check to see if it's installed and then skip the info
          env[:ui].info @translator.t("install", :provisioner => "chef-solo")
          env[:machine].communicate.execute(chef_install(env[:machine].guest))

          @app.call(env)
        end

        def chef_install(guest)
          read_script("chef", guest)
        end
      end
    end
  end
end
