require "pstore"

module Katalyst
  module Healthcheck
    # Represents a background task that runs periodically in an application
    class Task
      class << self
        def reset!
          File.delete(pstore_path) if File.exists?(pstore_path)
        end

        # @return tasks [Array<Task>] All tasks that have been registered
        def all
          result  = []
          storage = pstore
          storage.transaction(true) do
            tasks = storage[:tasks] || {}
            tasks.each do |name, attributes|
              result << Task.new(name,
                                 next_time:   attributes[:next_time],
                                 last_time:   attributes[:last_time],
                                 description: attributes[:description])
            end
          end
          result
        end

        # @param name [Symbol] name of the task
        def find(name)
          all.detect { |task| task.name == name.to_sym }
        end

        def write
          storage = pstore
          storage.transaction do
            yield storage
          end
        end

        private

        def pstore
          PStore.new(pstore_path)
        end

        def pstore_path
          Katalyst::Healthcheck.root.join("tmp/cache/healthcheck.pstore")
        end
      end

      attr_reader :name, :description, :last_time, :next_time

      # @param name [Symbol] The name of the background task
      # @param next_time [Date,Time] The time the task is next expected to complete successfully.
      # @param last_time [Date,Time] The time the task last completed successfully.
      # @param description [String] Optional description of this task
      def initialize(name, next_time:, last_time: nil, description: nil)
        @name        = name.to_sym
        @description = description
        @last_time   = last_time
        @next_time   = next_time
      end

      # @return [Boolean] true if this background task is running on schedule
      def ok?
        next_time.nil? || next_time + 10.minutes > Time.current
      end

      # @return [Symbol] status of this task. Either :ok or :fail
      def status
        ok? ? :ok : :fail
      end

      def to_s
        ok? ? "OK" : ["FAIL", description].compact.join(": ")
      end

      # Mark this task as complete
      def complete!
        self.class.write do |storage|
          storage[:version] = Katalyst::Healthcheck::VERSION
          tasks             = storage[:tasks] ||= {}
          tasks[name]       = {
            next_time:   next_time,
            last_time:   Time.current,
            description: description,
          }
        end
      end
    end
  end
end
