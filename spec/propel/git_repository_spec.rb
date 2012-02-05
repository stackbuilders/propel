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

    describe "when the process exits with a non-zero exit status" do
      it "should print the process stdout to the console and exit with the exit code of the process" do
        stub_shell do
          command 'git pull --rebase' do
            stdout 'my message'
            exitstatus 127
          end
        end
        
        git_repository = Propel::GitRepository.new
        git_repository.logger = stub_logger

        git_repository.logger.should_receive(:puts).with('my message')
        git_repository.pull(true)
      end
    end
  end

  describe "#ensure_attached_head!" do
    class DetachedHeadTrap < StandardError ; end

    it "should warn the user and exit with a status of 1 when the head is detached" do
      git_repository = Propel::GitRepository.new
      
      stub_shell { command('git branch') { stdout "* (no branch)\nmaster\n"  } }
      git_repository.should_receive(:exit_with_error).with('You are operating with a detached HEAD, aborting.').and_raise(DetachedHeadTrap)

      lambda {
        git_repository.ensure_attached_head!
      }.should raise_error(DetachedHeadTrap)
    end

    it "should not exit when on master branch" do
      git_repository = Propel::GitRepository.new
      stub_shell { command('git branch') { stdout "* master\notherbranch\n"  } }
      git_repository.should_not_receive(:exit_with_error)

      lambda {
        git_repository.ensure_attached_head!
      }.should_not raise_error(DetachedHeadTrap)
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

      stub_shell { command('git push -q') { exitstatus 1; stdout 'it failed'  } }
      
      git_repository.stub!(:remote_config)
      git_repository.stub!(:merge_config)

      git_repository.should_receive(:warn).with("Your push failed!  Please try again later.")
      
      lambda {
        git_repository.push  
      }.should raise_error(SystemExit)      
    end
  end

  describe "#project_root" do
    it "should return the root of the project" do
      project_root = File.expand_path(File.join(File.dirname(__FILE__), %w[ .. .. ]))
      stub_shell { command('git rev-parse --show-toplevel') { exitstatus 0; stdout project_root } }
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

      stub_shell { command('git fetch -q') { exitstatus 1; stdout 'it failed!'  } }
      git_repository.should_receive(:warn).with('Fetch of remote repository failed, exiting.')

      lambda { git_repository.fetch! }.should raise_error SystemExit
    end

    it "should call fetch without the quiet option (-q) if --verbose is specified" do
      git_repository = Propel::GitRepository.new
      git_repository.logger = stub_logger
      git_repository.options = {:verbose => true}

      stub_shell { command('git fetch') { stdout 'it worked!'  } }

      git_repository.fetch!
    end
  end

  describe "#changed?" do
    it "should return false when the remote branch has the same SHA1 as the local HEAD" do
      git_repository = Propel::GitRepository.new
      git_repository.logger = stub_logger

      stub_shell { 
        command('git fetch -q') { stdout 'ok, I fetched' }
        command('git branch') { stdout "* master\n  testbranch"  }
        command('git rev-parse HEAD') { stdout "ef2c8125b1923950a9cd776298516ad9ed3eb568\n"  }
        command('git config branch.master.remote') { stdout "origin\n"  }
        command('git config branch.master.merge') { stdout "refs/heads/master\n"  }
        command('git ls-remote origin refs/heads/master') { stdout "ef2c8125b1923950a9cd776298516ad9ed3eb568\n"  }
      }

      git_repository.should_not be_changed
    end

    it "should return true when the remote branch has a different SHA1 than the local HEAD" do
      git_repository = Propel::GitRepository.new
      git_repository.logger = stub_logger
      
      stub_shell { 
        command('git fetch -q') { stdout 'ok, I fetched' }
        command('git branch') { stdout "* master\n  testbranch"  }
        command('git rev-parse HEAD') { stdout "ef2c8125b1923950a9cd776298516ad9ed3eb568\n"  }
        command('git config branch.master.remote') { stdout "origin\n"  }
        command('git config branch.master.merge') { stdout "refs/heads/master\n"  }
        command('git ls-remote origin refs/heads/master') { stdout "bf2c8125b1923950a9cd776298516ad9ed3eb568\n"  }
      }
      
      git_repository.should be_changed
    end
  end

  describe "#remote_config" do
    it "should call the git command to determine the remote repository" do
      git_repository = Propel::GitRepository.new
      stub_shell { 
        command('git branch') { stdout "* master\n  testbranch"  } 
        command('git config branch.master.remote') { stdout "origin\n"  }
      }

      git_repository.remote_config.should == 'origin'
    end

    it "should raise an error if the remote repository cannot be determined" do
      git_repository = Propel::GitRepository.new

      stub_shell { 
        command('git branch') { stdout "* foo\n  testbranch"  } 
        command('git config branch.foo.remote') { stdout "\n"  }
      }

      git_repository.should_receive(:warn).with("We could not determine the remote repository for branch 'foo.' Please set it with git config branch.foo.remote REMOTE_REPO.")

      lambda { git_repository.remote_config }.should raise_error SystemExit
    end
  end

  describe "#merge_config" do
    it "should call the git command to determine the remote branch" do
      git_repository = Propel::GitRepository.new
      
      stub_shell { 
        command('git branch') { stdout "* master\n  testbranch"  } 
        command('git config branch.master.merge') { stdout "refs/heads/master\n"  }
      }
      
      git_repository.merge_config.should == 'refs/heads/master'
    end

    it "should raise an error if the remote branch cannot be determined" do
      git_repository = Propel::GitRepository.new

      stub_shell { 
        command('git branch') { stdout "* foo\n  testbranch"  } 
        command('git config branch.foo.merge') { stdout "\n"  }
      }
      
      git_repository.should_receive(:warn).with("We could not determine the remote branch for local branch 'foo.' Please set it with git config branch.foo.merge REMOTE_BRANCH.")
      lambda { git_repository.merge_config }.should raise_error SystemExit
    end
  end
end