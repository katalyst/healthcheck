# frozen_string_literal: true

require "date"

# Inspired by ActiveModel::Attributes, but with support for Rails 3+
module Katalyst
  module Healthcheck
    module Store
      module Attributes
        def self.included(klass)
          klass.extend ClassMethods
        end

        module ClassMethods
          @@attributes = {}

          def attribute(name, type = :string)
            name = name.to_s
            serializer = case type
                         when :integer
                           IntegerAttribute
                         when :datetime
                           DateTimeAttribute
                         else
                           Attribute
                         end
            define_method(name) { @@attributes[name].read(@attributes) }
            define_method("#{name}=") { |value| @@attributes[name].write(@attributes, value) }
            @@attributes[name] = serializer.new(name)
          end
        end

        def initialize(attributes)
          @attributes = {}
          self.attributes = attributes
        end

        def attributes
          @attributes.keys.map { |k| [k, public_send(k)] }.to_h
        end

        def attributes=(attributes)
          attributes.each do |k, v|
            public_send("#{k}=", v)
          end
          attributes
        end
      end

      class Attribute
        attr_reader :key

        def initialize(key)
          @key = key
        end

        def read(attributes)
          deserialize(attributes[key]) if attributes.has_key?(key)
        end

        def write(attributes, value)
          if value.nil?
            attributes.delete(key)
          elsif value.is_a?(String) # support already serialized values
            attributes[key] = value
          else
            attributes[key] = serialize(value)
          end
        end

        private

        def deserialize(value)
          value
        end

        def serialize(value)
          value.to_s
        end
      end

      class IntegerAttribute < Attribute
        private

        def deserialize(value)
          Integer(value)
        end
      end

      class DateTimeAttribute < Attribute
        private

        def serialize(value)
          value.iso8601
        end

        def deserialize(value)
          DateTime.parse(value)
        end
      end
    end
  end
end
