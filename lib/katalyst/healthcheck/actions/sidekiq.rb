module Katalyst
  module Healthcheck
    module Actions
      class Sidekiq
        include Katalyst::Healthcheck::Monitored

        define_task :sidekiq_health, "Sidekiq background processing", interval: 60

        class << self
          def call
            healthy! :sidekiq_health
          end
        end
      end
    end
  end
end
