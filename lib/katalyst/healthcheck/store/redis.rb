# frozen_string_literal: true

require "redis"

module Katalyst
  module Healthcheck
    module Store
      class Redis
        DEFAULT_CACHE_KEY = "katalyst_healthcheck_tasks"
        MAX_WRITE_TIME    = 5000 # milliseconds
        DEFAULT_OPTIONS   = {
          url:       "redis://localhost:6379",
          cache_key: DEFAULT_CACHE_KEY,
        }.freeze

        # @attr_reader options [OpenStruct] Redis configuration options
        attr_reader :options

        def initialize(options = DEFAULT_OPTIONS)
          @options = OpenStruct.new(options)
        end

        # @return [Array<Hash>] List of tasks attribute data
        def read
          data = fetch
          data["tasks"].values
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
          @client ||= ::Redis.new(options.to_h)
        end

        def lock_manager
          raise "redis url is required" if options.url.blank?

          @lock_manager ||= ::Redlock::Client.new([options.url])
        end
      end
    end
  end
end
