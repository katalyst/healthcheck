# frozen_string_literal: true

module Katalyst
  module Healthcheck
    # Represents a status and a message that can be used in a rails route
    class Route
      class << self
        def static(status, message)
          Proc.new { |_env| [status, { "Content-Type" => "text/plain" }, [message]] }
        end

        def from_tasks(detail: false)
          Proc.new do |_env|
            tasks = Task.all
            status = tasks.all?(&:ok?) ? 200 : 500
            message = status == 200 ? "OK" : "FAIL"
            message = Task.summary if detail
            [status, { "Content-Type" => "text/plain" }, [message]]
          end
        end
      end
    end
  end
end
