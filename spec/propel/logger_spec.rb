require 'spec_helper'

describe Propel::Logger do
  describe "#print" do
    it "should colorize the method when color is enabled and a color is provided" do
      logger = Propel::Logger.new({:color => true})
      Kernel.should_receive(:print).with("\e[32mHi\e[0m")

      logger.print('Hi', :green)
    end
  end

  describe "#puts" do
    it "should colorize the method when color is enabled and a color is provided" do
      logger = Propel::Logger.new({:color => true})
      Kernel.should_receive(:puts).with("\e[31mHi\e[0m")

      logger.puts('Hi', :red)
    end
  end

  describe "#warn" do
    it "should colorize the method when color is enabled and a color is provided" do
      logger = Propel::Logger.new({:color => true})
      Kernel.should_receive(:warn).with("\e[33mHi\e[0m")

      logger.warn('Hi', :yellow)
    end    
  end

  describe "#report_operation" do
    it "should return a formatted string" do
      logger = Propel::Logger.new({:color => true})
      Kernel.should_receive(:print).with("Doing something:                                            ")
      logger.report_operation('Doing something')
    end
  end

  describe "#report_status" do
    it "should return a formatted, colorized string" do
      logger = Propel::Logger.new({:color => true})
      Kernel.should_receive(:puts).with("[ \e[31mDONE\e[0m ]")
      logger.report_status('done', :red)
    end
  end
end