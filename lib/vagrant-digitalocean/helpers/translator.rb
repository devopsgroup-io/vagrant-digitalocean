module VagrantPlugins
  module DigitalOcean
    module Helpers
      class Translator
        def self.plugin_namespace=(val)
          @@plugin_namespace = val
        end

        def initialize(namespace)
          @namespace = namespace
        end

        def t(keys, opts = {})
          value = I18n.t("#{@@plugin_namespace}.#{@namespace}.#{keys}", opts)
          opts[:progress] == false ? value : value + " ..."
        end
      end
    end
  end
end
