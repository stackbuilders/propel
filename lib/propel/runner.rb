module Propel
  class Runner
    def initialize(args = [ ])
      @repository = GitRepository.new
      @options = Configuration.new(args, @repository).options
    end

    def start
      if @repository.changed?
        if remote_build_configured?
          check_remote_build! unless ignore_remote_build?

        else
          puts "Remote build is not configured, skipping check." if @options[:verbose]
        end

        propel!
      else
        puts "There is nothing to propel - your HEAD is identical to #{@repository.remote_config} #{@repository.merge_config}."
      end
    end

    private

    def check_remote_build!
      if @options[:wait]
        unless remote_build_green?
          wait_with_notice do
            log_wait_notice
            wait until remote_build_green?
            puts "\nThe build has been fixed."
          end
        end

      else
        
        alert_broken_build_and_exit unless remote_build_green?
      end
    end

    def wait_with_notice
      start_time = Time.now
      yield
      end_time = Time.now
      puts "We waited for #{(end_time - start_time).round} seconds while the build was failing."
    end

    def log_wait_notice
      puts "The remote build is failing, waiting until it is green to proceed."
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