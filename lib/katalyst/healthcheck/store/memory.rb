# frozen_string_literal: true

require "redis"

module Katalyst
  module Healthcheck
    module Store
      # In-memory store, intended for spec tests and debugging
      class Memory
        attr_reader :state

        def initialize(options = {})
          @options = options
          @state   = {}
        end

        # Read state from memory
        # @return [Array<Hash>] List of tasks attribute data
        def read
          state.values
        end

        # Write state to memory
        # @param name [String] name of the task
        # @param task_state [Hash,nil] Task state
        def update(name, task_state = {})
          if task_state.nil?
            state.delete(name)
          else
            state[name] = task_state
          end
        end

        # Remove task state
        # @param name [String] name of the task
        def delete(name)
          update(name, nil)
        end
      end
    end
  end
end
