# frozen_string_literal: true

module Katalyst
  module Healthcheck
    class Config
      attr_reader :store

      def initialize
        self.store = :redis
      end

      def store=(name)
        @store = build_store(name)
      end

      private

      def build_store(name)
        Object.const_get("Katalyst::Healthcheck::Store::#{name.to_s.capitalize}").new
      end
    end
  end
end
