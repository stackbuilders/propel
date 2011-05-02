require 'spec_helper'

describe Propel::OptionParser do
  describe ".parse!" do
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

    it "should set the status url based on the given parameters" do
      Propel::OptionParser.parse!(['--status-url', 'http://ci.example.com/feed.rss'])[:status_url].
          should == 'http://ci.example.com/feed.rss'
    end
  end
end