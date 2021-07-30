require 'rails_helper'

RSpec.describe Katalyst::Healthcheck::Task do
  let(:task) { described_class.new(:test_task, next_time: next_time) }
  let(:next_time) { Time.current + 1.day }

  describe "#complete!" do
    before do
      task.complete!
    end

    it "records task completion time" do
      expect(described_class.find(:test_task)&.next_time).to eq(next_time)
    end
  end

  describe "#ok?" do
    subject { task.ok? }

    context "when task next time has passed" do
      let(:next_time) { Time.current - 20.minutes }

      it { is_expected.to be_falsey }
    end

    context "when task next time is in the future" do
      let(:next_time) { Time.current + 1.day }

      it { is_expected.to be_truthy }
    end
  end
end
