module VagrantPlugins
  module DigitalOcean
    module Actions
      class MessageIsActive
        def initialize(app, env)
          @app = app
          @translator = Helpers::Translator.new("actions.message_is_active")
        end

        def call(env)
          msg = env[:is_active] ? "active" : "not_active"
          env[:ui].info @translator.t(msg)
          @app.call(env)
        end
      end
    end
  end
end
