module VagrantPlugins
  module DigitalOcean
    module Actions
      class IsActive
        def initialize(app, env)
          @app = app
        end

        def call(env)
          env[:is_active] = env[:machine].state.id == :active
          @app.call(env)
        end
      end
    end
  end
end
