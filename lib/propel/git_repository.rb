module Propel
  class GitRepository
    Result = Struct.new(:result, :exitstatus)

    attr_accessor :logger

    def self.changed?
      new.changed?
    end

    def project_root
      git("rev-parse --show-toplevel").result
    end

    def changed?
      local_last_commit != remote_last_commit
    end

    def pull(rebase)
      pull_cmd = 'pull'
      pull_cmd << ' --rebase' if rebase
      git pull_cmd
    end

    def push
      logger.report_operation "Pushing to #{remote_config} #{merge_config}"

      git('push -q').tap do
        logger.report_status('DONE', :green)
      end
    end

    def remote_config
      git("config branch.#{current_branch}.remote").result.tap do |remote|
        if remote.empty?
          warn  "We could not determine the remote repository for branch '#{current_branch}.' " +
                "Please set it with git config branch.#{current_branch}.remote REMOTE_REPO."
          exit 1
        end
      end
    end

    def merge_config
      git("config branch.#{current_branch}.merge").result.tap do |merge|
        if merge.empty?
          warn  "We could not determine the remote branch for local branch '#{current_branch}.' " +
                "Please set it with git config branch.#{current_branch}.merge REMOTE_BRANCH."
          exit 1
        end
      end
    end

    private
    def git git_args
      output = `git #{git_args}`.strip
      Result.new(output, $?)
    end

    def local_last_commit
      git("rev-parse HEAD").result
    end

    def remote_last_commit
      fetch!
      git("ls-remote #{remote_config} #{merge_config}").result.gsub(/\t.*/, '')
    end

    def current_branch
      # TODO - replace with:
      # git symbolic-ref HEAD
      git("branch").result.split("\n").detect{|l| l =~ /^\*/ }.gsub(/^\* /, '')
    end

    def fetch!
      logger.report_operation "Retrieving remote objects"

      git('fetch -q').tap do |result|
        if result.exitstatus != 0
          warn "Fetch of remote repository failed, exiting."
          exit 1
        else
          logger.report_status("DONE", :green)
        end
      end
    end
  end
end