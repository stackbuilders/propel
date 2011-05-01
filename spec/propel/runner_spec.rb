require 'spec_helper'

describe Propel::Runner do
  before do
    @git_repository = Propel::GitRepository.new
    Propel::GitRepository.should_receive(:new).and_return(@git_repository)
    @git_repository.stub!(:changed?).and_return(true)
  end

  describe ".start" do
    it "should not call propel! if there is nothing to push" do
      runner = Propel::Runner.new
      @git_repository.should_receive(:changed?).and_return(false)
      runner.should_not_receive(:propel!)
      runner.stub!(:puts)
      runner.start
    end

    it "should call propel! if there are changes to the current branch" do
      runner = Propel::Runner.new

      @git_repository.stub!(:changed?).and_return(true)
      @git_repository.stub!(:remote_config).and_return('origin')
      @git_repository.stub!(:remote_config).and_return('refs/heads/master')

      runner.should_receive(:propel!)
      runner.start
    end

    it "should call propel! if the remote build is configured and passing" do
      runner = Propel::Runner.new(%w[ --status-url http://ci.example.com/status ])
      runner.stub!(:remote_build_passing?).and_return(true)
      runner.stub!(:remote_build_configured?).and_return(true)

      runner.should_receive(:propel!)

      runner.start
    end

    it "should call propel! if the remote build is not configured" do
      runner = Propel::Runner.new
      runner.stub!(:remote_build_configured?).and_return false
      runner.should_receive(:propel!)

      runner.start
    end

    it "should raise an error and not call propel! if the remote build is configured but not passing" do
      runner = Propel::Runner.new
      runner.stub!(:remote_build_configured?).and_return true
      runner.stub!(:remote_build_passing?).and_return false
      
      runner.should_not_receive(:propel!)

      lambda {
        runner.start
      }.should raise_error(RuntimeError, "The remote build is broken. If your commit fixes the build, run propel with the --force (-f) option.")
    end

    it "should call propel! when the remote build is failing if --force is specified" do
      runner = Propel::Runner.new %w[ --force ]
      runner.stub!(:remote_build_configured?).and_return true
      runner.stub!(:remote_build_passing?).and_return false
      runner.should_receive(:propel!)

      runner.start
    end

    it "should call propel! when the remote build is not configured if --force is specified" do
      runner = Propel::Runner.new %w[ --force ]
      runner.stub!(:remote_build_configured?).and_return false

      runner.should_receive(:propel!)

      runner.start
    end

    it "should run a command using pull --rebase by default" do
      runner = Propel::Runner.new
      
      runner.should_receive(:system).with("git pull --rebase && rake && git push")
      runner.start
    end

    it "should run a command using pull without --rebase when --no-rebase is specified" do
      runner = Propel::Runner.new(['--no-rebase'])
      runner.should_receive(:system).with("git pull && rake && git push")
      runner.start
    end

    it "should wait for the build to pass if the user specifies the --wait option" do
      runner = Propel::Runner.new(['--wait'])
      runner.stub!(:remote_build_configured?).and_return true

      runner.should_receive(:remote_build_green?).twice.and_return(false, true)

      runner.stub!(:print).with('.')
      runner.stub!(:sleep).with(10)
      
      runner.should_receive(:propel!)
      runner.start
    end
  end
end