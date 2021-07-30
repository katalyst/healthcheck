module Katalyst
  module Healthcheck
    class TasksController < ApplicationController
      def index
        @tasks = Task.all
        @ok    = @tasks.all?(&:ok?)
        render status: @ok ? :ok : 500
      end

      def show
        @task = Task.find(params[:id])

        if @task.nil?
          head :not_found
        else
          response.status = @task.ok? ? :ok : 500
        end
      end
    end
  end
end
