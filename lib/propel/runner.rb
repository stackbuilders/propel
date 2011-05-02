module Propel
  class Runner
    def initialize(args = [ ])
      @options = Configuration.new(args).options
    end

    def start
      git_repository = GitRepository.new

      if git_repository.changed?
        if remote_build_configured?
          unless ignore_remote_build?
            alert_broken_build_and_exit unless remote_build_passing?
          end

        else
          puts "Remote build is not configured, skipping check." if @options[:verbose]
        end

        propel!
      else
        puts "There is nothing to propel - your HEAD is identical to #{git_repository.remote_config} #{git_repository.merge_config}."
      end
    end

    private

    def remote_build_passing?
      if @options[:wait]
        wait until remote_build_green?
        true

      else
        remote_build_green?
      end
    end
    
    def alert_broken_build_and_exit
      msg = <<-EOS
        The remote build is broken. If your commit fixes the build, run propel with the --force (-f) option.
        If you're waiting for someone else to fix the build, use propel with --wait (-w).
      EOS

      $stderr.puts msg.split("\n").map(&:strip)
      exit 1
    end

    def ignore_remote_build?
      @options[:force]
    end

    def remote_build_configured?
      !@options[:status_url].nil?
    end

    def wait
      print "."
      STDOUT.flush
      sleep 5
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