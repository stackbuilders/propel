module Propel
  class Configuration
    def initialize(command_line_arguments, repository)
      @command_line_options = command_line_arguments
      @repository = repository
    end

    DEFAULTS = {
        :fix_ci    => false,
        :rebase   => true,
        :verbose  => false,
        :wait     => false
    }

    def options
      DEFAULTS.merge(parse(options_from_config_file).merge(parse @command_line_options))
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