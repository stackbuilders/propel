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
        
        parser.on('-s', '--status-url STATUS_URL', 'Location of build status feed') do |build_status_url|
          options[:status_url] = build_status_url
        end

        parser.on('-f', '--[no-]force', 'Ignores any remote build failures') do |o|
          options[:force] = o
        end

        parser.on('-r', '--[no-]rebase', 'Determines whether or not pull uses rebase.  Propel uses rebase by default.') do |o|
          options[:rebase] = o
        end

        parser.on('-w', '--[no-]wait', 'Waits for fixes to remote build') do |o|
          options[:wait] = o
        end

        parser.on('-v', '--verbose', 'Shows extra information') do |o|
          options[:verbose] = o
        end
      end
    end
  end
end