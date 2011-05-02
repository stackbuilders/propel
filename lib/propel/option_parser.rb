require 'optparse'

module Propel
  class OptionParser

    def self.parse!(args = [ ])
      new.parse!(args)
    end

    def parse!(args)
      options = {}
      parser(options).parse!(args)
      options
    end

    def parser(options)
      ::OptionParser.new do |parser|
        parser.banner = "Usage: propel [options]\n\n"
        
        options[:force]   = false
        options[:rebase]  = true
        options[:verbose] = false
        options[:wait]    = false

        parser.on('-s', '--status-url STATUS_URL', 'Location of build status feed') do |build_status_url|
          options[:status_url] = build_status_url
        end

        parser.on('-f', '--[no-]force', 'Use propel --force to ignore any remote build failures') do |o|
          options[:force] = o
        end

        parser.on('-r', '--[no-]rebase', 'Use propel --no-rebase. Defaults to --rebase') do |o|
          options[:rebase] = o
        end

        parser.on('-w', '--[no-]wait', 'Wait for the remote build to pass if it is currently failing.  Use propel --wait.') do |o|
          options[:wait] = o
        end

        parser.on('-v', '--verbose', 'Use propel --verbose.') do |o|
          options[:verbose] = o
        end
      end
    end
  end
end