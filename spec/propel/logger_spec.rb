require 'spec_helper'

describe Propel::Logger do
  describe "#print" do
    it "should print the message when quiet mode is disabled" do
      logger = Propel::Logger.new({:quiet => false})
      Kernel.should_receive(:print).with('Hi')

      logger.print('Hi')
    end

    it "should not print the message when quiet mode is enabled" do
      logger = Propel::Logger.new({:quiet => true})
      Kernel.should_not_receive(:print).with('Hi')

      logger.print('Hi')
    end

    it "should colorize the method when color is enabled and a color is provided" do
      logger = Propel::Logger.new({:quiet => false, :color => true})
      Kernel.should_receive(:print).with("\e[32mHi\e[0m")

      logger.print('Hi', :green)
    end
  end

  describe "#puts" do
    it "should puts the message when quiet mode is disabled" do
      logger = Propel::Logger.new({:quiet => false})
      Kernel.should_receive(:puts).with('Hi')

      logger.puts('Hi')
    end

    it "should not puts the message when quiet mode is enabled" do
      logger = Propel::Logger.new({:quiet => true})
      Kernel.should_not_receive(:puts).with('Hi')

      logger.puts('Hi')
    end

    it "should colorize the method when color is enabled and a color is provided" do
      logger = Propel::Logger.new({:quiet => false, :color => true})
      Kernel.should_receive(:puts).with("\e[31mHi\e[0m")

      logger.puts('Hi', :red)
    end
  end

  describe "#warn" do
    it "should warn the message when quiet mode is disabled" do
      logger = Propel::Logger.new({:quiet => false})
      Kernel.should_receive(:warn).with('Hi')

      logger.warn('Hi')
    end

    it "should not warn the message when quiet mode is enabled" do
      logger = Propel::Logger.new({:quiet => true})
      Kernel.should_not_receive(:warn).with('Hi')

      logger.warn('Hi')
    end

    it "should colorize the method when color is enabled and a color is provided" do
      logger = Propel::Logger.new({:quiet => false, :color => true})
      Kernel.should_receive(:warn).with("\e[33mHi\e[0m")

      logger.warn('Hi', :yellow)
    end    
  end
end