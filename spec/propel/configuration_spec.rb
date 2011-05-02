require 'spec_helper'

describe Propel::Configuration do
  describe "#options" do
    it "should prefer options given on the command line over options in a configuration file" do
      configuration = Propel::Configuration.new(['--rebase'])
      configuration.stub!(:options_from_config_file).and_return(['--no-rebase'])

      configuration.options[:rebase].should be_true
    end

    it "should not overwrite options from config file with defaults" do
      configuration = Propel::Configuration.new([])
      configuration.stub!(:options_from_config_file).and_return(['--wait'])

      configuration.options[:wait].should be_true
    end

    it "should set default options" do
      configuration = Propel::Configuration.new([])
      configuration.stub!(:options_from_config_file).and_return([])

      configuration.options.should == { :rebase => true, :force => false, :verbose => false, :wait => false}
    end    
  end
end