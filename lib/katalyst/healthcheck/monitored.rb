# frozen_string_literal: true

module Katalyst
  module Healthcheck
    module Monitored
      def self.included(klass)
        klass.extend(ClassMethods)
      end

      module ClassMethods
        # Define a task to be monitored
        # @param name [Symbol] The name of the task
        # @param description [String] A description of the task's function
        # @param interval [Integer,ActiveSupport::Duration] Expected frequency that this task runs, e.g. 1.day
        def define_healthcheck_task(name, description, interval:)
          defined_healthcheck_tasks[name] = Task.new(name: name, description: description, interval: interval)
        end
        alias define_task define_healthcheck_task

        # @return [Hash] Defined tasks keyed by name
        def defined_healthcheck_tasks
          @defined_healthcheck_tasks ||= {}
        end

        # Mark a task as healthy
        # @param name [Symbol] The name of the task
        def healthy!(name)
          find_or_create_task(name).healthy!
        end

        # Mark a task as unhealthy
        # @param name [Symbol] The name of the task
        # @param error [String] Optional error message
        def unhealthy!(name, error = nil)
          find_or_create_task(name).unhealthy!(error)
        end

        private

        def find_or_create_task(name)
          task = Task.find(name)
          if task.nil?
            task = defined_healthcheck_tasks[name]
            raise "task #{name} not found" if task.nil?

            task.save
          end
          task
        end
      end

      # Mark a task as healthy
      # @param name [Symbol] The name of the task
      def healthy!(name)
        self.class.healthy! name
      end

      # Mark a task as unhealthy
      # @param name [Symbol] The name of the task
      # @param error [String] Optional error message
      def unhealthy!(name, error = nil)
        self.class.unhealthy! name, error
      end
    end
  end
end
