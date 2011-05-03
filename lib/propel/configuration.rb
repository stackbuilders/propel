module Propel
  class Configuration

    def initialize(command_line_arguments, repository)
      @command_line_options = command_line_arguments
      @repository = repository
    end

    DEFAULTS = {
        :color   => false,
        :fix_ci  => false,
        :rebase  => true,
        :verbose => false,
        :wait    => false
    }

    def options
      opts = DEFAULTS.merge(parse(options_from_config_file).merge(parse @command_line_options))
      correct_color_setting!(opts)
    end

    def correct_color_setting!(opts)
      if opts[:color_enabled] && RUBY_PLATFORM =~ /mswin|mingw/
        unless ENV['ANSICON']
          warn "You must use ANSICON 1.31 or later (http://adoxa.110mb.com/ansicon/) to use colour on Windows"
          opts[:color] = false
        end
      end
      
      opts
    end

    def config_file
      File.join(@repository.project_root, ".propel")
    end
    
    private
    def options_from_config_file
      File.exist?(config_file) ? File.read(config_file).split : [ ]
    end

    def parse(option_array)
      Propel::OptionParser.parse!(option_array)
    end
  end
end