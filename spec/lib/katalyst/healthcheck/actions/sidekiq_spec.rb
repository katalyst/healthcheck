# frozen_string_literal: true

RSpec.describe Katalyst::Healthcheck::Actions::Sidekiq do
  subject { action }

  let(:action) { described_class }

  before do
    allow(action).to receive(:healthy!)
  end

  it "marks sidekiq as healthy" do
    action.call
    expect(action).to have_received(:healthy!)
  end
end
