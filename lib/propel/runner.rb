module Propel
  class Runner
    COLORS = {
        :red    => 31,
        :green  => 32,
        :yellow => 33,
    }

    def initialize(args = [ ])
      @repository = GitRepository.new
      @options = Configuration.new(args, @repository).options
    end

    def start
      if @repository.changed?
        if remote_build_configured?
          check_remote_build! unless @options[:fix_ci]

        else
          warn "Remote build is not configured, you should point propel to the status URL of your CI server."
          
        end

        propel!
      else
        puts color("There is nothing to propel - your HEAD is identical to #{@repository.remote_config} #{@repository.merge_config}.", :green)
      end
    end

    private

    def color(message, color_sym)
      @options[:color] ? "\e[#{COLORS[color_sym]}m#{message}\e[0m" : message
    end

    def check_remote_build!
      print "CI server status:\t"
      STDOUT.flush

      waited_for_build = false
      if @options[:wait]
        unless remote_build_green?
          waited_for_build = true
          
          say_duration do
            puts color("FAILING", :red)
            puts "Waiting until the CI build is green to proceed."
            wait until remote_build_green?
            puts color("\nThe CI build has been fixed.", :green)
          end
        end

      else
        
        alert_broken_build_and_exit unless remote_build_green?
      end

      puts color("PASSING", :green) unless waited_for_build
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

      warn color(msg.split("\n").map(&:strip), :red)
      exit 1
    end

    def remote_build_configured?
      !@options[:status_url].nil?
    end

    def wait
      print color(".", :yellow)
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