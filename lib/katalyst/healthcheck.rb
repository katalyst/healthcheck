# frozen_string_literal: true

require "active_support/all"
require "redlock"

require "katalyst/healthcheck/version"
require "katalyst/healthcheck/railtie" if defined?(Rails)
require "katalyst/healthcheck/config"
require "katalyst/healthcheck/store/attributes"
require "katalyst/healthcheck/store/memory"
require "katalyst/healthcheck/store/redis"
require "katalyst/healthcheck/task"
require "katalyst/healthcheck/monitored"
require "katalyst/healthcheck/route"
require "katalyst/healthcheck/actions/sidekiq" if defined?(Sidekiq)

module Katalyst
  module Healthcheck
    class << self
      def config
        @config ||= Config.new
      end

      def configure
        instance_eval(&:block)
      end
    end
  end
end
