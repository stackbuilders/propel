module Propel
  class GitRepository
    def self.changed?
      new.changed?
    end

    def project_root
      git("rev-parse --show-toplevel")
    end

    def changed?
      local_last_commit != remote_last_commit
    end

    def remote_config
      git("config branch.#{current_branch}.remote")
    end

    def merge_config
      git("config branch.#{current_branch}.merge")
    end

    private
    def git git_args
      `git #{git_args}`.strip
    end

    def local_last_commit
      git("rev-parse HEAD")
    end

    def remote_last_commit
      fetch!
      git("ls-remote #{remote_config} #{merge_config}").gsub(/\t.*/, '')
    end

    def current_branch
      git("branch").split("\n").detect{|l| l =~ /^\*/ }.gsub(/^\* /, '')
    end

    def fetch!
      git("fetch")
    end
  end
end