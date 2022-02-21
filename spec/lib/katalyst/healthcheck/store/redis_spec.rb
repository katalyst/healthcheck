# frozen_string_literal: true

module Rails
  class Application
    def config_for(name); end
  end
end

RSpec.describe Katalyst::Healthcheck::Store::Redis do
  subject { store }

  let(:store) { described_class.new(cache_key: "test") }
  let(:state) { { "description" => "test description" } }
  let(:store_tasks) { store.read || [] }

  describe "#initialize" do
    it "sets redis url" do
      expect(store.options[:url]).to eq("redis://localhost:6379")
    end

    context "with a url in constructor" do
      let(:store) { described_class.new(url: "redis://other-host:2000") }

      it "uses defined redis url" do
        expect(store.options[:url]).to eq("redis://other-host:2000")
      end
    end

    context "with rails config" do
      let(:redis_config) { { host: "redis-host", port: 9000 } }
      let(:application) { instance_double(Rails::Application) }

      before do
        allow(Rails).to receive(:application).and_return(application)
        allow(application).to receive(:config_for).with(:redis).and_return(redis_config)
      end

      it "sets redis url" do
        expect(store.options[:url]).to eq("redis://redis-host:9000")
      end
    end
  end

  describe "#read" do
    it "fetches tasks state" do
      tasks = store.read
      expect(tasks).to be_kind_of(Array)
    end
  end

  describe "#update" do
    it "saves task state" do
      store.update("task", state)
      expect(store_tasks).to include(state)
    end
  end
end
