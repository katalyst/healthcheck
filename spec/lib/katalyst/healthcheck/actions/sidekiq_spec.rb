# frozen_string_literal: true

RSpec.describe Katalyst::Healthcheck::Actions::Sidekiq do
  subject { action }

  let(:action) { described_class.new }
  let(:task) { Katalyst::Healthcheck::Task.find(:sidekiq_health) }

  before { task.unhealthy! }

  it "marks sidekiq as healthy" do
    expect { action.perform }.to change { task.reload.ok? }.to(true)
  end
end
