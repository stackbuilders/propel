module Propel
  class GitRepository
    Result = Struct.new(:result, :exitstatus)

    attr_accessor :logger, :options

    def initialize
      @options = { :verbose => false }
    end

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

      git(verbosity_for('push')).tap do |result|
        if result.exitstatus != 0
          logger.report_status("FAILING", :red)
          exit_with_error "Your push failed!  Please try again later."
        end

        logger.report_status('DONE', :green)
      end
    end

    def remote_config
      git("config branch.#{current_branch}.remote").result.tap do |remote|
        if remote.empty?
          exit_with_error  "We could not determine the remote repository for branch '#{current_branch}.' " +
                           "Please set it with git config branch.#{current_branch}.remote REMOTE_REPO."
        end
      end
    end

    def merge_config
      git("config branch.#{current_branch}.merge").result.tap do |merge|
        if merge.empty?
          exit_with_error  "We could not determine the remote branch for local branch '#{current_branch}.' " +
                           "Please set it with git config branch.#{current_branch}.merge REMOTE_BRANCH."
        end
      end
    end

    def fetch!
      logger.report_operation "Retrieving remote objects"

      git(verbosity_for('fetch')).tap do |result|
        if result.exitstatus != 0
          exit_with_error "Fetch of remote repository failed, exiting."
        end

        logger.report_status("DONE", :green)
      end
    end

    private
    def exit_with_error(message)
      warn message
      exit 1
    end

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
      # TODO - replace with git symbolic-ref HEAD
      git("branch").result.split("\n").detect{|l| l =~ /^\*/ }.gsub(/^\* /, '')
    end

    def verbosity_for(git_operation)
      @options[:verbose] ? git_operation : "#{git_operation} -q"
    end
  end
end