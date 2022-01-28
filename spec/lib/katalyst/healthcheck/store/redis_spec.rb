# frozen_string_literal: true

RSpec.describe Katalyst::Healthcheck::Store::Redis do
  subject { store }

  let(:store) { described_class.new }
  let(:state) { { "description" => "test description" } }
  let(:store_tasks) { store.read || [] }

  before do
    store.options.cache_key = "test"
  end

  describe "read" do
    it "fetches tasks state" do
      tasks = store.read
      expect(tasks).to be_kind_of(Array)
    end
  end

  describe "update" do
    it "saves task state" do
      store.update("task", state)
      expect(store_tasks).to include(state)
    end
  end
end
