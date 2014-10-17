module Xinge
  module Utils
    module AttrsMethodsGenerator
      extend ActiveSupport::Concern

      private

      def generate_attrs_methods(attrs, options)
        attrs.each do |method|
          self.class.send :define_method, method do
            options[method]
          end

          self.class.send :define_method, "#{method.to_s}=" do |value|
            options[method] = value
          end
        end
      end
    end
  end
end
