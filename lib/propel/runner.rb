module Propel
  class Runner
    attr_reader :logger, :repository
    
    def initialize(args = [ ])
      @repository = GitRepository.new
      @options    = Configuration.new(args, @repository).options
      @logger     = Logger.new(@options)

      @repository.logger  = @logger
      @repository.options = @options
    end

    def start
      if @repository.changed?
        if remote_build_configured?

          if @options[:fix_ci]
            logger.puts("Thanks for trying to fix the build!", :green)
          else
            check_remote_build!
          end

        else
          logger.warn "Remote build is not configured, you should point propel to the status URL of your CI server."

        end

        propel!
      else
        logger.puts("There is nothing to propel - your HEAD is identical to #{@repository.remote_config} #{@repository.merge_config}.", :green)

      end
    end

    private

    def check_remote_build!
      logger.report_operation "CI server status"

      waited_for_build = false
      if @options[:wait]
        unless remote_build_green?
          waited_for_build = true
          
          say_duration do
            logger.report_status("FAILING", :red)
            logger.puts "Waiting until the CI build is green."
            wait until remote_build_green?
            logger.puts("\nThe CI build has been fixed.", :green)
          end
        end

      else
        
        alert_broken_build_and_exit unless remote_build_green?
      end

      logger.report_status("PASSING", :green) unless waited_for_build
    end

    def say_duration
      start_time = Time.now
      yield
      end_time = Time.now
      logger.puts("We waited for #{(end_time - start_time).round} seconds while the build was failing.")
    end

    def alert_broken_build_and_exit
      logger.puts("FAILING", :red)

      msg = <<-EOS
The remote build is broken. If your commit fixes the build, run propel with --fix-ci (-f).
If you're waiting for someone else to fix the build, use propel with --wait (-w).
      EOS

      logger.puts("")
      warn msg
      exit 1
    end

    def remote_build_configured?
      !@options[:status_url].nil?
    end

    def wait
      logger.print(".", :yellow)
      sleep 5
    end

    def remote_build_green?
      RemoteBuild.new(@options[:status_url]).passing?
    end

    def propel!
      Propel.new(@repository, @options[:rebase]).start
    end
  end
end