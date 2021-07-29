module Katalyst
  module Healthcheck
    class Engine < ::Rails::Engine
      isolate_namespace Katalyst::Healthcheck
    end
  end
end
