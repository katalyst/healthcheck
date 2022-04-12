# frozen_string_literal: true

module Katalyst
  module Healthcheck
    # Represents a background task that runs periodically in an application
    class Task
      include Store::Attributes

      TASK_GRACE_PERIOD = 10 * 60 # 10 minutes

      class << self
        # @return tasks [Array<Task>] All tasks that have been registered
        def all
          store.read.map { |i| Task.new(i) }
        end

        # @param name [Symbol] name of the task
        def find(name)
          all.find { |task| task.name == name.to_s }
        end

        def find!(name)
          find(name) || raise("Undefined task '#{name}'")
        end

        def destroy!(name)
          store.delete(name)
        end

        def store
          Katalyst::Healthcheck.config.store
        end

        # @return [String] Summary of task status
        def summary
          output = []
          all.each do |task|
            output << "#{task.name}:"
            fields = [
              ["Status", task.ok? ? "OK" : "FAIL"],
              ["Description", task.description],
              ["Error", task.error],
            ]
            fields.select { |i| i[1] }.each { |i| output << "  #{i.join(': ')}" }
          end

          output.join("\n")
        end
      end

      attribute :name
      attribute :last_time, :datetime
      attribute :created_at, :datetime
      attribute :updated_at, :datetime
      attribute :interval, :integer
      attribute :status
      attribute :error
      attribute :server
      attribute :description

      def ok?
        status&.to_sym != :fail && on_schedule?
      end

      # @return [Boolean] true if this background task is running on schedule
      def on_schedule?
        next_time.nil? || next_time + TASK_GRACE_PERIOD > DateTime.now
      end

      def next_time
        return nil if interval.nil?

        (last_time || created_at) + interval
      end

      # Mark this task as healthy and save state
      # @return [Task] This task
      def healthy!
        self.last_time = DateTime.now
        self.error     = nil
        self.status    = :ok

        save
      end

      # Mark this task as unhealthy and save state
      # @return [Task] This task
      def unhealthy!(error = nil)
        self.error  = error || "Fail"
        self.status = :fail

        save
      end

      # Save task state
      # @return [Task] This task
      def save
        self.created_at ||= DateTime.now
        self.updated_at = DateTime.now
        store.update(name, attributes)
        self
      end

      def reload
        Task.find(name)
      end

      private

      def store
        self.class.store
      end
    end
  end
end
