module Propel
  class Logger
    COLORS = {
        :red    => 31,
        :green  => 32,
        :yellow => 33,
    }

    def initialize(configuration)
      @configuration = configuration
    end

    def print(message, color_sym = nil)
      unless @configuration[:quiet]
        Kernel.print color(message, color_sym)
        STDOUT.flush
      end
    end

    def puts(message, color_sym = nil)
      Kernel.puts color(message, color_sym) unless @configuration[:quiet]
    end

    def warn(message, color_sym = nil)
      Kernel.warn color(message, color_sym) unless @configuration[:quiet]
    end

    private
    
    def color(message, color_sym)
      if @configuration[:color] && color_sym
        "\e[#{COLORS[color_sym]}m#{message}\e[0m"
      else
        message
      end
    end
  end
end