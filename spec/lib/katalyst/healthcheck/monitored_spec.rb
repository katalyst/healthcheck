# frozen_string_literal: true

require "spec_helper"

module Test
  class MonitoredTask
    include Katalyst::Healthcheck::Monitored

    define_healthcheck_task :task, "test task", interval: 86400

    def call(success: true)
      if success
        healthy!(:task)
      else
        unhealthy!(:task)
      end

      self
    end
  end

  class MonitoredTaskWithoutDefinedTask
    include Katalyst::Healthcheck::Monitored

    def call(success: true)
      healthy!(:undefined_task)

      self
    end
  end
end

RSpec.describe Katalyst::Healthcheck::Monitored do
  subject { task }

  let(:task) { Katalyst::Healthcheck::Task.find(:task) }
  let(:monitored_task) { Test::MonitoredTask.new }
  let(:undefined_task) { Test::MonitoredTaskWithoutDefinedTask.new }
  let(:task_called) { true }
  let(:success) { true }

  before do
    monitored_task.call(success: success) if task_called
  end

  describe "healthy!" do
    let(:success) { true }

    it { is_expected.to be_ok }

    context "without a defined task" do
      it "raises an exception" do
        expect { undefined_task.call(success: success) }.to raise_exception("task undefined_task not found")
      end
    end
  end

  describe "unhealthy!" do
    let(:success) { false }

    it { is_expected.not_to be_ok }

    context "without a defined task" do
      it "raises an exception" do
        expect { undefined_task.call(success: success) }.to raise_exception("task undefined_task not found")
      end
    end
  end

  describe "define_healthcheck_task" do
    context "when task has never run but has a defined interval" do
      let(:task_called) { false }

      it { is_expected.not_to be_ok }
    end
  end
end
