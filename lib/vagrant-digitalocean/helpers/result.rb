module VagrantPlugins
  module DigitalOcean
    module Helpers
      class Result
        def initialize(body)
          # handle/raise exceptions
          @result = body
        end

        def [](key)
          @result[key.to_s]
        end

        def find_id(sub_obj, name)
          @result[sub_obj.to_s].inject(nil) do |id, obj|
            obj["name"] == name ? obj["id"] : id
          end
        end
      end
    end
  end
end
