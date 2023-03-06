# frozen_string_literal: true

require "redis"
require "json"

module Katalyst
  module Healthcheck
    module Store
      class Redis
        DEFAULT_CACHE_KEY = "katalyst_healthcheck_tasks"
        MAX_WRITE_TIME    = 5000 # milliseconds
        DEFAULT_HOST      = ENV.fetch("DEFAULT_REDIS_HOST", "localhost")
        DEFAULT_PORT      = ENV.fetch("DEFAULT_REDIS_PORT", "6379")
        DEFAULT_OPTIONS   = {
          url:       "redis://#{DEFAULT_HOST}:#{DEFAULT_PORT}",
          cache_key: DEFAULT_CACHE_KEY,
        }.freeze

        class << self
          # @return [String] Redis URL defined in rails config
          def rails_redis_url
            ENV.fetch("REDIS_URL") do
              redis_config = rails_redis_config || {}
              host         = redis_config["host"] || DEFAULT_HOST
              port         = redis_config["port"] || DEFAULT_PORT
              "redis://#{host}:#{port}"
            end
          end

          def rails_redis_config
            Rails.application&.config_for(:redis)
          rescue StandardError
            {}
          end
        end

        # @attr_reader options [OpenStruct] Redis configuration options
        attr_reader :options

        def initialize(options = {})
          options  = { url: self.class.rails_redis_url }.merge(options) if defined?(Rails)
          options  = DEFAULT_OPTIONS.merge(options)
          namespaced_cache_key = [ENV["RAILS_ENV"], options[:cache_key]].compact.join("_")
          @options = Struct.new(:url, :cache_key).new(options[:url], namespaced_cache_key)
        end

        # @return [Array<Hash>] List of tasks attribute data
        def read
          data  = fetch
          tasks = data["tasks"] || {}
          tasks.values
        end

        # Write task state
        # @param name [String] name of the task
        # @param task_state [Hash,nil] task details. If null, task state will be removed
        def update(name, task_state = {})
          lock_manager.lock!("#{cache_key}_lock", MAX_WRITE_TIME, {}) do
            now                = Time.now
            data               = fetch
            data["version"]    = Katalyst::Healthcheck::VERSION
            data["updated_at"] = now
            data["created_at"] ||= now
            task_data          = data["tasks"] ||= {}
            if task_state.nil?
              task_data.delete(name)
            else
              task_data[name] = task_state
            end
            client.set(cache_key, JSON.generate(data))
          end
        end

        # Remove task state
        # @param name [String] name of the task
        def delete(name)
          update(name, nil)
        end

        private

        def cache_key
          options.cache_key || DEFAULT_CACHE_KEY
        end

        # @return [Hash] Redis data for all tasks
        def fetch
          data = JSON.parse(client.get(cache_key) || "{}")
          data = {} if data["version"] != Katalyst::Healthcheck::VERSION
          data
        end

        def client
          @client ||= ::Redis.new(url: options.url)
        end

        def lock_manager
          raise "redis url is required" unless options.url

          @lock_manager ||= ::Redlock::Client.new([options.url])
        end
      end
    end
  end
end
