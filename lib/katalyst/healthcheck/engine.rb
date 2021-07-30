module Katalyst
  module Healthcheck
    class Engine < ::Rails::Engine
      isolate_namespace Katalyst::Healthcheck

      initializer "my_engine.load_app_root" do |app|
        Katalyst::Healthcheck.root = app.root
      end

      initializer "static assets" do |app|
        app.config.assets.precompile += %w(
          katalyst/healthcheck/application.css
        )
      end

    end
  end
end
