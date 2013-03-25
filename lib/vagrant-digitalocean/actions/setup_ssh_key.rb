require "vagrant-digitalocean/helpers/client"

module VagrantPlugins
  module DigitalOcean
    module Actions
      class SetupSSHKey
        include Helpers::Client
  
        def initialize(app, env)
          @app, @env = app, env
          @client = client
          @translator = Helpers::Translator.new("actions.setup_ssh_key")
        end

        # TODO check the content of the key to see if it has changed
        def call(env)
          ssh_key_name = env[:machine].provider_config.ssh_key_name

          begin
            # assigns existing ssh key id to env for use by other commands
            env[:ssh_key_id] = @client
              .request("/ssh_keys/")
              .find_id(:ssh_keys, :name => ssh_key_name)

            env[:ui].info @translator.t("existing_key", { :name => ssh_key_name })
          rescue Errors::ResultMatchError
            env[:ssh_key_id] = create_ssh_key(ssh_key_name, env)
          end

          @app.call(env)
        end

        private

        def create_ssh_key(name, env)
          # assumes public key exists on the same path as private key with .pub ext
          path = env[:machine].provider_config.ssh_private_key_path
          path = env[:machine].config.ssh.private_key_path if !path
          path = File.expand_path("#{path}.pub", env[:machine].env.root_path)

          env[:ui].info @translator.t("new_key", { :name => name, :path => path })
          begin
            file = File.open(path)
            key = file.read
            file.close
          rescue
            raise Errors::PublicKeyError,
              :path => path
          end

          result = @client.request("/ssh_keys/new", {
            :name => name,
            :ssh_pub_key => key
          })
          result["ssh_key"]["id"]
        end
      end
    end
  end
end
