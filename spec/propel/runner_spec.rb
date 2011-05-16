require 'spec_helper'

describe Propel::Runner do
  before do
    @git_repository = Propel::GitRepository.new
    Propel::GitRepository.should_receive(:new).and_return(@git_repository)
    @git_repository.stub!(:changed?).and_return(true)
  end

  describe ".start" do
    class DetachedHeadTrap < StandardError ; end

    it "should not call propel! if HEAD is detached" do
      runner = Propel::Runner.new
      runner.stub!(:logger).and_return(stub_logger)
      @git_repository.stub!(:ensure_attached_head!).and_raise(DetachedHeadTrap)

      runner.should_not_receive(:propel!)

      lambda {
        runner.start
      }.should raise_error(DetachedHeadTrap)
    end
    
    it "should not call propel! if there is nothing to push" do
      runner = Propel::Runner.new
      runner.stub!(:logger).and_return(stub_logger)

      @git_repository.should_receive(:changed?).and_return(false)
      runner.should_not_receive(:propel!)
      runner.start
    end

    it "should call propel! if there are changes to the current branch" do
      runner = Propel::Runner.new
      runner.stub!(:logger).and_return(stub_logger)

      @git_repository.stub!(:changed?).and_return(true)
      @git_repository.stub!(:remote_config).and_return('origin')
      @git_repository.stub!(:remote_config).and_return('refs/heads/master')

      runner.should_receive(:propel!)
      runner.start
    end

    it "should call propel! if the remote build is configured and passing" do
      runner = Propel::Runner.new(%w[ --status-url http://ci.example.com/status ])
      
      runner.stub!(:remote_build_configured?).and_return(true)
      runner.stub!(:remote_build_green?).and_return(true)

      runner.stub!(:logger).and_return(stub_logger)

      runner.should_receive(:propel!)
      runner.start
    end

    it "should call propel! if the remote build is not configured" do
      runner = Propel::Runner.new
      runner.stub!(:remote_build_configured?).and_return false
      runner.should_receive(:propel!)
      runner.stub!(:logger).and_return(stub_logger)

      runner.logger.should_receive(:warn).with("Remote build is not configured. You should point propel to the status URL of your CI server.")

      runner.start
    end

    class TestError < StandardError ; end
    it "should send an alert about the broken build if the remote build is configured but not passing" do
      runner = Propel::Runner.new
      runner.stub!(:remote_build_configured?).and_return true
      runner.stub!(:remote_build_green?).and_return false

      runner.should_receive(:alert_broken_build_and_exit).and_raise(TestError.new("Execution should be aborted here"))
      runner.should_not_receive(:propel!)

      runner.stub!(:logger).and_return(stub_logger)
      
      lambda {
        runner.start
      }.should raise_error(TestError)
    end

    it "should call propel! when the remote build is failing if --fix-ci is specified" do
      runner = Propel::Runner.new %w[ --fix-ci ]
      runner.stub!(:remote_build_configured?).and_return true
      runner.logger.should_receive(:puts).with("Thanks for trying to fix the build!", :green)
      runner.stub!(:remote_build_passing?).and_return false
      runner.should_receive(:propel!)

      runner.start
    end

    it "should call propel! when the remote build is not configured if --fix-ci is specified" do
      runner = Propel::Runner.new %w[ --fix-ci ]
      runner.stub!(:remote_build_configured?).and_return false

      runner.logger.should_receive(:warn).with("Remote build is not configured. You should point propel to the status URL of your CI server.")
      runner.should_receive(:propel!)

      runner.start
    end

    it "should wait for the build to pass if the user specifies the --wait option" do
      runner = Propel::Runner.new(%w[--wait])
      runner.stub!(:remote_build_configured?).and_return true
      runner.stub!(:logger).and_return(stub_logger)
      
      runner.should_receive(:remote_build_green?).twice.and_return(false, true)

      runner.should_receive(:say_duration).and_yield

      runner.should_receive(:propel!)
      runner.start
    end
  end
end