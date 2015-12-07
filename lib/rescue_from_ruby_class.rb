require "rescue_from_ruby_class/version"
require "active_support"

module RescueFromRubyClass
  extend ActiveSupport::Concern
  include ActiveSupport::Rescuable

  module ClassMethods
    def with_rescue_block(exception_class, &blk)
      instance_eval do
        rescue_from(exception_class, &blk)
      end

      methods_to_remove = [:rescue_handlers?, :rescue_handlers=, :rescue_handlers]

      instance_methods = self.instance_methods(false) - methods_to_remove
      instance_methods.each do |name|
        method = instance_method(name)
        define_method(name) do |*args, &block|
          begin
            method.bind(self).call(*args, &block)
          rescue exception_class => ex
            rescue_with_handler(ex) || raise
          end
        end
      end

      class_methods = self.methods(false) - methods_to_remove
      class_methods.each do |name|
        method = method(name)
        define_singleton_method(name) do |*args, &block|
          begin
            method.call(*args, &block)
          rescue exception_class => ex
            self.new.rescue_with_handler(ex) || raise
          end
        end
      end
    end
  end
end
