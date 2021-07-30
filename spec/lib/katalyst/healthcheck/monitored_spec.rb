# frozen_string_literal: true

require "rails_helper"

module Test
  class MonitoredTask
    include Katalyst::Healthcheck::Monitored

    define_task :task, "test task", interval: 86400

    def call(success: true)
      if success
        healthy!(:task)
      else
        unhealthy!(:task)
      end

      self
    end
  end
end

RSpec.describe Katalyst::Healthcheck::Monitored do
  subject { task }

  let(:task) { Katalyst::Healthcheck::Task.find(:task) }
  let(:monitored_task) { Test::MonitoredTask.new }
  let(:task_called) { true }
  let(:success) { true }

  before do
    monitored_task.call(success: success) if task_called
  end

  describe "healthy!" do
    let(:success) { true }

    it { is_expected.to be_ok }
  end

  describe "unhealthy!" do
    let(:success) { false }

    it { is_expected.not_to be_ok }
  end

  describe "define_task" do
    context "when task has never run but has a defined interval" do
      let(:task_called) { false }

      around do |example|
        travel 1.day do
          example.run
        end
      end

      it { is_expected.not_to be_ok }
    end
  end
end
