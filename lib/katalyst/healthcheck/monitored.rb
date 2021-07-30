# frozen_string_literal: true

module Katalyst
  module Healthcheck
    module Monitored
      extend ActiveSupport::Concern

      module HealthMethods
        # Define a task to be monitored
        # @param name [Symbol] The name of the task
        # @param description [String] A description of the task's function
        # @param interval [Integer,ActiveSupport::Duration] Expected frequency that this task runs, e.g. 1.day
        def define_task(name, description, interval:)
          task = Task.new(name: name, description: description, interval: interval)
          task.save
        end

        # Mark a task as healthy
        # @param name [Symbol] The name of the task
        def healthy!(name)
          Task.find!(name).healthy!
        end

        # Mark a task as unhealthy
        # @param name [Symbol] The name of the task
        # @param error [String] Optional error message
        def unhealthy!(name, error = nil)
          Task.find!(name).unhealthy!(error)
        end
      end

      class_methods do
        include HealthMethods
      end

      include HealthMethods
    end
  end
end
