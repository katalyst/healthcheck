# frozen_string_literal: true

require "sidekiq"

module Katalyst
  module Healthcheck
    module Actions
      class Sidekiq
        include Katalyst::Healthcheck::Monitored
        include ::Sidekiq::Worker

        sidekiq_options retry: false

        define_healthcheck_task :sidekiq_health, "Sidekiq background processing", interval: 60

        def self.call
          perform_async
        end

        def perform
          self.class.healthy! :sidekiq_health
        end
      end
    end
  end
end
