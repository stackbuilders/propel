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

      configuration.options.should == { :rebase => true, :fix_ci => false, :verbose => false, :wait => false, :color => false }
    end

    it "should correct the color setting if on a Windows 32 system that does not support color" do
      configuration = Propel::Configuration.new(['--color', '--quiet'], Propel::GitRepository.new)
      configuration.stub(:ruby_platform).and_return('mswin')
      configuration.stub!(:warn)
      configuration.options[:color].should be_false
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