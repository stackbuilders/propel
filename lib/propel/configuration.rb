module Propel
  class Configuration
    def initialize(command_line_arguments)
      @command_line_options = command_line_arguments
    end

    def options
      parse(options_from_config_file).merge(parse @command_line_options)
    end

    private
    def options_from_config_file
      File.exist?(config_file) ? File.read(config_file).split : [ ]
    end

    def parse(option_array)
      Propel::OptionParser.parse!(option_array)
    end

    def config_file
      './.propel'
    end
  end
end