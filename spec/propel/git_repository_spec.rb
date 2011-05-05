require 'spec_helper'

describe Propel::GitRepository do
  describe "#pull" do
    it "should use --rebase when argument is true" do
      git_repository = Propel::GitRepository.new
      git_repository.should_receive(:git).with("pull --rebase")
      git_repository.pull(true)
    end

    it "should not use --rebase when argument as false" do
      git_repository = Propel::GitRepository.new
      git_repository.should_receive(:git).with("pull")
      git_repository.pull(false)
    end
  end

  describe "#push" do
    it "should call 'push -q' by default" do
      git_repository = Propel::GitRepository.new
      git_repository.logger = stub_logger

      git_repository.should_receive(:git).with('push -q').and_return(Propel::GitRepository::Result.new('all good', 0))
      git_repository.stub!(:remote_config)
      git_repository.stub!(:merge_config)

      git_repository.push
    end
    
    it "should call push without -q if --verbose is specified" do
      git_repository = Propel::GitRepository.new
      git_repository.logger = stub_logger
      git_repository.options = {:verbose => true}
      
      git_repository.should_receive(:git).with('push').and_return(Propel::GitRepository::Result.new('all good', 0))
      git_repository.stub!(:remote_config)
      git_repository.stub!(:merge_config)
      git_repository.push
    end

    it "should warn the user and exit with a status of 1 if the push fails" do
      git_repository = Propel::GitRepository.new
      git_repository.logger = stub_logger

      git_repository.should_receive(:git).with('push -q').and_return(Propel::GitRepository::Result.new('bad!', 1))
      
      git_repository.stub!(:remote_config)
      git_repository.stub!(:merge_config)

      git_repository.should_receive(:warn).with("Your push failed!  Please try again later.")
      git_repository.should_receive(:exit).with(1)
      
      git_repository.push
    end
  end

  describe "#project_root" do
    it "should return the root of the project" do
      project_root = File.expand_path(File.join(File.dirname(__FILE__), %w[ .. .. ]))
      Propel::GitRepository.new.project_root.should == project_root
    end
  end

  describe ".changed?" do
    it "should call #changed? on a new instance of the GitRepository" do
      git_repository = Propel::GitRepository.new
      git_repository.should_receive(:changed?)
      Propel::GitRepository.should_receive(:new).and_return git_repository

      Propel::GitRepository.changed?
    end
  end

  describe "#fetch!" do
    it "should exit with a not-0 status and warn the user if the fetch fails" do
      git_repository = Propel::GitRepository.new
      git_repository.logger = stub_logger

      git_repository.should_receive(:git).with('fetch -q').and_return(Propel::GitRepository::Result.new('', 1))

      git_repository.should_receive(:exit).with(1)
      git_repository.should_receive(:warn).with('Fetch of remote repository failed, exiting.')

      git_repository.fetch!
    end

    it "should call fetch without the quiet option (-q) if --verbose is specified" do
      git_repository = Propel::GitRepository.new
      git_repository.logger = stub_logger
      git_repository.options = {:verbose => true}

      git_repository.should_receive(:git).with('fetch').and_return(Propel::GitRepository::Result.new('', 0))

      git_repository.fetch!
    end
  end

  describe "#changed?" do
    it "should return false when the remote branch has the same SHA1 as the local HEAD" do
      git_repository = Propel::GitRepository.new
      git_repository.stub!(:fetch!)
      git_repository.stub!(:git).with("branch").and_return(Propel::GitRepository::Result.new("* master\n  testbranch", 0))

      git_repository.should_receive(:git).with("rev-parse HEAD").and_return(Propel::GitRepository::Result.new("ef2c8125b1923950a9cd776298516ad9ed3eb568", 0))
      git_repository.should_receive(:git).with("config branch.master.remote").and_return(Propel::GitRepository::Result.new("origin", 0))
      git_repository.should_receive(:git).with("config branch.master.merge").and_return(Propel::GitRepository::Result.new("refs/heads/master", 0))

      git_repository.should_receive(:git).with("ls-remote origin refs/heads/master").and_return(Propel::GitRepository::Result.new("ef2c8125b1923950a9cd776298516ad9ed3eb568\trefs/heads/master", 0))

      git_repository.should_not be_changed
    end

    it "should return true when the remote branch has a different SHA1 than the local HEAD" do
      git_repository = Propel::GitRepository.new
      git_repository.stub!(:fetch!)
      git_repository.stub!(:git).with("branch").and_return(Propel::GitRepository::Result.new("* master\n  testbranch", 0))

      git_repository.should_receive(:git).with("rev-parse HEAD").and_return(Propel::GitRepository::Result.new("ef2c8125b1923950a9cd776298516ad9ed3eb568", 0))
      git_repository.should_receive(:git).with("config branch.master.remote").and_return(Propel::GitRepository::Result.new("origin", 0))
      git_repository.should_receive(:git).with("config branch.master.merge").and_return(Propel::GitRepository::Result.new("refs/heads/master", 0))

      git_repository.should_receive(:git).with("ls-remote origin refs/heads/master").and_return(Propel::GitRepository::Result.new("bf2c8125b1923950a9cd776298516ad9ed3eb568\trefs/heads/master", 0))

      git_repository.should be_changed
    end
  end

  describe "#remote_config" do
    it "should call the git command to determine the remote repository" do
      git_repository = Propel::GitRepository.new
      git_repository.stub!(:git).with("branch").and_return(Propel::GitRepository::Result.new("* master\n  testbranch", 0))
      git_repository.should_receive(:git).with("config branch.master.remote").and_return(Propel::GitRepository::Result.new("origin", 0))

      git_repository.remote_config.should == 'origin'
    end

    it "should raise an error if the remote repository cannot be determined" do
      git_repository = Propel::GitRepository.new

      git_repository.stub!(:git).with("branch").and_return(Propel::GitRepository::Result.new("* foo\n  testbranch", 0))
      git_repository.stub!(:git).with("config branch.foo.remote").and_return(Propel::GitRepository::Result.new("", 0))

      git_repository.should_receive(:warn).with("We could not determine the remote repository for branch 'foo.' Please set it with git config branch.foo.remote REMOTE_REPO.")
      git_repository.should_receive(:exit).with(1)

      git_repository.remote_config
    end
  end

  describe "#merge_config" do
    it "should call the git command to determine the remote branch" do
      git_repository = Propel::GitRepository.new
      git_repository.stub!(:git).with("branch").and_return(Propel::GitRepository::Result.new("* master\n  testbranch", 0))
      git_repository.should_receive(:git).with("config branch.master.merge").and_return(Propel::GitRepository::Result.new("refs/heads/master", 0))

      git_repository.merge_config.should == 'refs/heads/master'
    end

    it "should raise an error if the remote branch cannot be determined" do
      git_repository = Propel::GitRepository.new

      git_repository.stub!(:git).with("branch").and_return(Propel::GitRepository::Result.new("* foo\n  testbranch", 0))
      git_repository.stub!(:git).with("config branch.foo.merge").and_return(Propel::GitRepository::Result.new("", 0))

      git_repository.should_receive(:warn).with("We could not determine the remote branch for local branch 'foo.' Please set it with git config branch.foo.merge REMOTE_BRANCH.")
      git_repository.should_receive(:exit).with(1)
      git_repository.merge_config
    end
  end
end