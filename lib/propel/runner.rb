module Propel
  class Runner
    def initialize(args = [ ])
      @repository = GitRepository.new
      @options = Configuration.new(args, @repository).options
    end

    def start
      if @repository.changed?
        if remote_build_configured?
          check_remote_build! unless @options[:fix_ci]

        else
          $stderr.puts "Remote build is not configured, you should point propel to the status URL of your CI server."
          
        end

        propel!
      else
        puts "There is nothing to propel - your HEAD is identical to #{@repository.remote_config} #{@repository.merge_config}."
      end
    end

    private

    def check_remote_build!
      puts "Checking remote build..."
      if @options[:wait]
        unless remote_build_green?
          say_duration do
            log_wait_notice
            puts "The remote build is failing, waiting until it is green to proceed."
            wait until remote_build_green?
            puts "\nThe build has been fixed."
          end
        end

      else
        
        alert_broken_build_and_exit unless remote_build_green?
      end

      puts "Remote build is passing."
    end

    def say_duration
      start_time = Time.now
      yield
      end_time = Time.now
      puts "We waited for #{(end_time - start_time).round} seconds while the build was failing."
    end

    def alert_broken_build_and_exit
      msg = <<-EOS
        The remote build is broken. If your commit fixes the build, run propel with the --fix-ci (-f) option.
        If you're waiting for someone else to fix the build, use propel with --wait (-w).
      EOS

      $stderr.puts msg.split("\n").map(&:strip)
      exit 1
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