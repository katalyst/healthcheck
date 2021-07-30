require "katalyst/healthcheck/version"
require "katalyst/healthcheck/engine"
require "katalyst/healthcheck/task"

module Katalyst
  module Healthcheck
    class << self
      attr_accessor :root

      # Record completion of a background task
      # @param name [Symbol] The name of the task
      # @param next_time [Date,Time] The time the task is next expected to complete successfully.
      # @param description [String] Optional description of this task
      def complete_task!(name, next_time:, description: nil)
        Task.new(name, next_time: next_time, description: description).complete!
      end
    end
  end
end
