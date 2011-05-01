require 'spec_helper'

describe Propel::RemoteBuild do
  before do
    @remote_build = Propel::RemoteBuild.new('http://ci.example.com/someProject.rss')
  end

  describe "#passing?" do
    it "should retrieve the contents of the configured URL" do
      Net::HTTP.stub!(:get).with(URI.parse('http://ci.example.com/someProject.rss')).and_return File.read(File.join(File.dirname(__FILE__), %w[ .. fixtures jenkins passing_build.rss ]))
      @remote_build.passing?
    end

    describe "with a Jenkins build feed" do
      it "should return true if the tests are passing" do
        @remote_build.stub!(:retrieve_test_results).and_return(File.read(File.join(File.dirname(__FILE__), %w[ .. fixtures jenkins passing_build.rss ])))
        @remote_build.passing?.should be_true
      end

      it "should return false if the tests are not passing" do
        @remote_build.stub!(:retrieve_test_results).and_return(File.read(File.join(File.dirname(__FILE__), %w[ .. fixtures jenkins failing_build.rss ])))
        @remote_build.passing?.should be_false
      end
    end

    describe "with a TeamCity build feed" do
      it "should return true if the tests are passing" do
        @remote_build.stub!(:retrieve_test_results).and_return(File.read(File.join(File.dirname(__FILE__), %w[ .. fixtures team_city passing_build.rss ])))
        @remote_build.passing?.should be_true
      end

      it "should return false if the tests are not passing" do
        @remote_build.stub!(:retrieve_test_results).and_return(File.read(File.join(File.dirname(__FILE__), %w[ .. fixtures team_city failing_build.rss ])))
        @remote_build.passing?.should be_false
      end
    end

    describe "with a CI Joe build feed" do
      it "should return true if the tests are passing" do
        @remote_build.stub!(:retrieve_test_results).and_return(File.read(File.join(File.dirname(__FILE__), %w[ .. fixtures ci_joe passing_build.json ])))
        @remote_build.passing?.should be_true
      end

      it "should return false if the tests are not passing" do
        @remote_build.stub!(:retrieve_test_results).and_return(File.read(File.join(File.dirname(__FILE__), %w[ .. fixtures ci_joe failing_build.json ])))
        @remote_build.passing?.should be_false
      end
    end
  end
end

