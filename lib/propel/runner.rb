module Propel
  class Runner
    def initialize(args = [ ])
      @options = Configuration.new(args).options
    end

    def start
      git_repository = GitRepository.new

      if git_repository.changed?
        check_remote_build! unless ignore_remote_build?
        propel!
      else
        puts "There is nothing to propel - your HEAD is identical to #{git_repository.remote_config} #{git_repository.merge_config}."
      end
    end

    private

    def check_remote_build!
      if remote_build_configured?

        if !remote_build_passing?
          raise "The remote build is broken. If your commit fixes the build, run propel with the --force (-f) option."
        end

      else
        puts "Remote build is not configured, skipping check." if @options[:verbose]
      end
    end

    def ignore_remote_build?
      @options[:force]
    end

    def remote_build_configured?
      !@options[:status_url].nil?
    end

    def remote_build_passing?
      if @options[:wait]
        until remote_build_green? do
          print "."
          sleep 10
        end

        true
      else
        remote_build_green?
      end
    end

    def remote_build_green?
      RemoteBuild.new(@options[:status_url]).passing?
    end

    def propel!
      pull_cmd = 'git pull'
      pull_cmd << ' --rebase' if @options[:rebase]
      system [ pull_cmd, 'rake', 'git push' ].join(' && ')
    end
  end
end