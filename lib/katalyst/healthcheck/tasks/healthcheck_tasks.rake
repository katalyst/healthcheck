# frozen_string_literal: true

namespace :katalyst_healthcheck do
  desc "Display health check information"
  task info: :environment do
    puts Katalyst::Healthcheck::Task.summary
  end

  desc "Clear status for a health check task"
  task clear_task: :environment do
    task_name = ENV["task_name"]
    if task_name.nil?
      puts "usage: rake #{ARGV[0]} task_name=name\n  task name is required."
      exit 1
    end

    Katalyst::Healthcheck::Task.destroy!(task_name)
    puts "cleared task status for task: #{task_name}"
  end

  desc "Call the sidekiq health check action to check that sidekiq is able to process background tasks"
  task sidekiq: :environment do
    Katalyst::Healthcheck::Actions::Sidekiq.delay(retry: false).call
  end
end
