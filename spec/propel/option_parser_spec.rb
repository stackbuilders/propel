require 'spec_helper'

describe Propel::OptionParser do
  describe ".parse!" do
    it "should set default options" do
      Propel::OptionParser.parse!.should == {:rebase => true, :force => false, :verbose => false, :wait => false}
    end

    it "should set force to true when given as an option" do
      Propel::OptionParser.parse!(['--force'])[:force].should be_true
    end

    it "should set rebase to false when given as an option" do
      Propel::OptionParser.parse!(['--no-rebase'])[:rebase].should be_false
    end

    it "should set verbose to true when given as an option" do
      Propel::OptionParser.parse!(['--verbose'])[:verbose].should be_true
    end

    it "should set wait to true when given as an option" do
      Propel::OptionParser.parse!(['--wait'])[:wait].should be_true
    end
  end
end