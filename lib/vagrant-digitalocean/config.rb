module VagrantPlugins
  module DigitalOcean
    class Config < Vagrant.plugin("2", :config)
      attr_accessor :client_id, :api_key, :image, :region, :size, :ca_path,
                    :ssh_key_name, :ssh_private_key_path

      def initialize
        @client_id        = UNSET_VALUE
        @api_key          = UNSET_VALUE
        @image            = UNSET_VALUE
        @region           = UNSET_VALUE
        @size             = UNSET_VALUE
        @ca_path          = UNSET_VALUE
        @ssh_key_name     = UNSET_VALUE
        @pub_ssh_key_path = UNSET_VALUE

        @translator = Helpers::Translator.new("config")
      end

      def finalize!
        @client_id             = ENV["DO_CLIENT_ID"] if @client_id == UNSET_VALUE
        @api_key               = ENV["DO_API_KEY"] if @api_key == UNSET_VALUE
        @image                 = "Ubuntu 12.04 x32 Server" if @image == UNSET_VALUE
        @region                = "New York 1" if @region == UNSET_VALUE
        @size                  = "512MB" if @size == UNSET_VALUE
        @ca_path               = nil if @ca_path == UNSET_VALUE
        @ssh_key_name          = "Vagrant" if @ssh_key_name == UNSET_VALUE
        @ssh_private_key_path  = nil if @ssh_private_key_path == UNSET_VALUE
      end

      def validate(machine)
        errors = []
        errors << @translator.t(:client_id_required) if !@client_id
        errors << @translator.t(:api_key_required) if !@api_key

        key = @ssh_private_key_path
        key = machine.config.ssh.private_key_path if !@ssh_private_key_path

        if !key
          errors << @translator.t(:private_key_required) if !key
        elsif !File.file?(File.expand_path(key, machine.env.root_path))
          errors << @translator.t(:private_key_missing, { :key => key })
        elsif !File.file?(File.expand_path("#{key}.pub", machine.env.root_path))
          errors << @translator.t(:public_key_missing, { :key => key })
        end

        { "Digital Ocean Provider" => errors }
      end
    end
  end
end
