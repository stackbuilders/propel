require 'spec_helper'

describe Propel::Configuration do
  describe "#options" do
    it "should prefer options given on the command line over options in a configuration file" do
      configuration = Propel::Configuration.new(['--rebase'])
      configuration.stub!(:options_from_config_file).and_return(['--no-rebase'])

      configuration.options[:rebase].should be_true
    end
  end
end