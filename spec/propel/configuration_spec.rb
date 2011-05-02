require 'spec_helper'

describe Propel::Configuration do
  describe "#options" do
    it "should prefer options given on the command line over options in a configuration file" do
      configuration = Propel::Configuration.new(['--rebase'], Propel::GitRepository.new)
      configuration.stub!(:options_from_config_file).and_return(['--no-rebase'])

      configuration.options[:rebase].should be_true
    end

    it "should not overwrite options from config file with defaults" do
      configuration = Propel::Configuration.new([], Propel::GitRepository.new)
      configuration.stub!(:options_from_config_file).and_return(['--wait'])

      configuration.options[:wait].should be_true
    end

    it "should set default options" do
      configuration = Propel::Configuration.new([], Propel::GitRepository.new)
      configuration.stub!(:options_from_config_file).and_return([])

      configuration.options.should == { :rebase => true, :force => false, :verbose => false, :wait => false}
    end    
  end

  describe "#config_file" do
    it "should return a file located in the project root" do
      git_repository = Propel::GitRepository.new
      git_repository.stub!(:project_root).and_return('/foo/testdirectory')

      configuration = Propel::Configuration.new([], git_repository)
      configuration.config_file.should == '/foo/testdirectory/.propel'
    end
  end
end