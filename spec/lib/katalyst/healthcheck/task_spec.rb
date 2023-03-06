# frozen_string_literal: true

RSpec.describe Katalyst::Healthcheck::Task do
  let(:task) { described_class.new(name: :test_task, interval: interval, last_time: last_time) }
  let(:interval) { 60 * 20 } # seconds
  let(:last_time) { DateTime.now - (interval / 2) }

  before do
    Katalyst::Healthcheck.config.store = :memory
  end

  describe "#attributes" do
    it { expect(task).to have_attributes(name: "test_task", interval: interval, last_time: last_time) }
  end

  describe "#healthy!" do
    subject { action }

    let(:action) { task.healthy! }

    it { expect { action }.to change(task, :status).to("ok") }
    it { expect { action }.to change(task, :last_time) }
  end

  describe "#unhealthy!" do
    subject { action }

    let(:action) { task.unhealthy! }

    it { expect { action }.to change(task, :status).to("fail") }
    it { expect { action }.not_to change(task, :last_time) }
  end

  describe "#next_time" do
    let(:last_time) { DateTime.new(2023, 3, 6, 10, 00) }
    let(:interval) { 600 } # 10 minutes

    it { expect(task.next_time).to eq(DateTime.new(2023, 3, 6, 10, 10)) }
  end

  describe "#ok?" do
    subject { task.ok? }

    context "when task has not run when expected" do
      let(:last_time) { DateTime.now - (interval * 2) }

      it { is_expected.to be_falsey }
    end

    context "when task has run less than interval seconds ago" do
      let(:last_time) { Time.now - (interval / 2) }

      it { is_expected.to be_truthy }
    end

    context "when task was marked as unhealthy" do
      before do
        task.unhealthy!
      end

      it { is_expected.to be_falsey }
    end

    context "when task was marked as healthy" do
      before do
        task.unhealthy!
        task.healthy!
      end

      it { is_expected.to be_truthy }
    end
  end

  describe "summary" do
    def create_task(options = {})
      Katalyst::Healthcheck::Task.new(options).save
    end

    before do
      Katalyst::Healthcheck.config.store = :memory

      create_task(name:        :task1,
                  description: "Task 1 description",
                  status:      :ok)
      create_task(name:        :task2,
                  description: "Task 2 description",
                  status:      :fail,
                  error:       "Something went wrong")
    end

    describe "tasks_detail" do
      subject { described_class.summary }

      let(:expected_details) do
        <<~DETAILS
          task1:
            Status: OK
            Description: Task 1 description
          task2:
            Status: FAIL
            Description: Task 2 description
            Error: Something went wrong
        DETAILS
      end

      it { is_expected.to eq(expected_details.chomp) }
    end
  end
end
