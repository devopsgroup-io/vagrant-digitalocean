module VagrantPlugins
  module DigitalOcean
    module Actions
      # TODO move bash to actual bash scripts, and serialize
      class SetupProvisioner
        def initialize(app, env)
          @app, @env = app, env
        end

        def call(env)
          env[:machine].communicate.sudo(chef_repo)
          env[:machine].communicate.sudo(chef_install)
          @app.call(env)
        end

        def chef_repo
          <<-BASH
            if [-e /etc/apt/sources.list.d/opscode.list]; then exit 0; fi;
            apt-get install -y wget lsb-release;
            echo "deb http://apt.opscode.com/ `lsb_release -cs`-0.10 main" | sudo tee /etc/apt/sources.list.d/opscode.list;
            mkdir -p /etc/apt/trusted.gpg.d;
            gpg --keyserver keys.gnupg.net --recv-keys 83EF826A;
            gpg --export packages@opscode.com | sudo tee /etc/apt/trusted.gpg.d/opscode-keyring.gpg > /dev/null;
          BASH
        end

        # TODO use subdirectory with vagrant as the orgname
        def chef_install
          <<-BASH
            if (which chef-solo); then exit 0; fi;
            apt-get update;

            # avoid server url popup
            echo "chef chef/chef_server_url string https://api.opscode.com/organizations/vagrant" | debconf-set-selections && apt-get install chef -y;
          BASH
        end
      end
    end
  end
end
