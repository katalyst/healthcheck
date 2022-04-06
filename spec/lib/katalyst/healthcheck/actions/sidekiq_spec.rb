# frozen_string_literal: true

require "sidekiq/testing"

RSpec.describe Katalyst::Healthcheck::Actions::Sidekiq do
  subject { action }

  let(:action) { described_class }
  let(:task) { described_class.defined_healthcheck_tasks[:sidekiq_health] }

  before { task.unhealthy! }

  around { |test| Sidekiq::Testing.inline! { test.call } }

  it "marks sidekiq as healthy" do
    expect { action.call }.to change { task.reload.ok? }.to(true)
  end
end
