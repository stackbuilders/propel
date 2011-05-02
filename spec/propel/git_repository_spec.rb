require 'spec_helper'

describe Propel::GitRepository do
  describe ".changed?" do
    it "should call #changed? on a new instance of the GitRepository" do
      git_repository = Propel::GitRepository.new
      git_repository.should_receive(:changed?)
      Propel::GitRepository.should_receive(:new).and_return git_repository
      
      Propel::GitRepository.changed?
    end
  end

  describe "#project_root" do
    it "should return the root of the project" do
      project_root = File.expand_path(File.join(File.dirname(__FILE__), %w[ .. .. ]))
      Propel::GitRepository.new.project_root.should == project_root
    end
  end
  
  describe "#changed?" do
    it "should return false when the remote branch has the same SHA1 as the local HEAD" do
      git_repository = Propel::GitRepository.new
      git_repository.stub!(:fetch!)
      git_repository.stub!(:git).with("branch").and_return("* master\n  testbranch")

      git_repository.should_receive(:git).with("rev-parse HEAD").and_return("ef2c8125b1923950a9cd776298516ad9ed3eb568")
      git_repository.should_receive(:git).with("config branch.master.remote").and_return("origin")
      git_repository.should_receive(:git).with("config branch.master.merge").and_return("refs/heads/master")

      git_repository.should_receive(:git).with("ls-remote origin refs/heads/master").and_return("ef2c8125b1923950a9cd776298516ad9ed3eb568\trefs/heads/master")

      git_repository.should_not be_changed
    end

    it "should return true when the remote branch has a different SHA1 than the local HEAD" do
      git_repository = Propel::GitRepository.new
      git_repository.stub!(:fetch!)
      git_repository.stub!(:git).with("branch").and_return("* master\n  testbranch")

      git_repository.should_receive(:git).with("rev-parse HEAD").and_return("ef2c8125b1923950a9cd776298516ad9ed3eb568")
      git_repository.should_receive(:git).with("config branch.master.remote").and_return("origin")
      git_repository.should_receive(:git).with("config branch.master.merge").and_return("refs/heads/master")

      git_repository.should_receive(:git).with("ls-remote origin refs/heads/master").and_return("bf2c8125b1923950a9cd776298516ad9ed3eb568\trefs/heads/master")

      git_repository.should be_changed
    end
  end

  describe "#remote_config" do
    it "should call the git command to determine the remote repository" do
      git_repository = Propel::GitRepository.new
      git_repository.stub!(:git).with("branch").and_return("* master\n  testbranch")
      git_repository.should_receive(:git).with("config branch.master.remote").and_return("origin")

      git_repository.remote_config.should == 'origin'
    end
  end

  describe "#merge_config" do
    it "should call the git command to determine the remote branch" do
      git_repository = Propel::GitRepository.new
      git_repository.stub!(:git).with("branch").and_return("* master\n  testbranch")
      git_repository.should_receive(:git).with("config branch.master.merge").and_return("refs/heads/master")

      git_repository.merge_config.should == 'refs/heads/master'
    end
  end
end