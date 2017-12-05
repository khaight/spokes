module Spokes
  module Config
    class Env
      def self.load(&blk)
        new(&blk)
      end

      def initialize(&blk)
        instance_eval(&blk)
      end

      def mandatory(name, method = nil)
        value = cast(ENV.fetch(name.to_s.upcase), method)
        create(name, value)
      end

      def optional(name, method = nil)
        value = cast(ENV[name.to_s.upcase], method)
        create(name, value)
      end

      def default(name, default, method = nil)
        value = cast(ENV.fetch(name.to_s.upcase, default), method)
        create(name, value)
      end

      def array
        ->(v) { v.nil? ? [] : v.split(',') }
      end

      def int
        ->(v) { v.to_i }
      end

      def float
        ->(v) { v.to_f }
      end

      def bool
        ->(v) { v.to_s == 'true' }
      end

      def string
        nil
      end

      def symbol
        ->(v) { v.nil? ? nil : v.to_sym }
      end

      private

      def cast(value, method)
        method ? method.call(value) : value
      end

      def create(name, value)
        instance_variable_set(:"@#{name}", value)
        instance_eval "def #{name}; @#{name} end", __FILE__, __LINE__
        return unless value.is_a?(TrueClass) || value.is_a?(FalseClass) || value.is_a?(NilClass)
        instance_eval "def #{name}?; !!@#{name} end", __FILE__, __LINE__
      end
    end
  end
end
