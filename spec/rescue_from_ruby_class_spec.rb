require 'spec_helper'
require 'active_support/core_ext/kernel/reporting'

describe RescueFromRubyClass do
  before(:all) do
    class ArbitraryRubyClass
      include RescueFromRubyClass

      def self.arbitrary_class_method
        raise "Class Method Exception message!"
      end

      def arbitrary_instance_method
        raise "Instance Method Exception message!"
      end

      with_rescue_block(StandardError) do |exception|
        puts "Exception Message: #{exception.message}\nFrom Rescue Block!"
        puts exception.message
      end
    end
  end

  it 'has a version number' do
    expect(RescueFromRubyClass::VERSION).not_to be nil
  end

  it 'rescues from exceptions for class methods' do
    expect(STDOUT).to receive(:puts).with("Exception Message: Class Method Exception message!\nFrom Rescue Block!")
    expect(STDOUT).to receive(:puts).with("Class Method Exception message!")
    ArbitraryRubyClass.arbitrary_class_method
  end

  it 'rescues from exceptions for instance methods' do
    expect(STDOUT).to receive(:puts).with("Exception Message: Instance Method Exception message!\nFrom Rescue Block!")
    expect(STDOUT).to receive(:puts).with("Instance Method Exception message!")
    ArbitraryRubyClass.new.arbitrary_instance_method
  end
end
