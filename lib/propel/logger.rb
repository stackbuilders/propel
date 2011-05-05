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
      Kernel.puts color(message, color_sym)
    end

    def warn(message, color_sym = nil)
      Kernel.warn color(message, color_sym)
    end

    def report_operation(message)
      if @configuration[:verbose]
        Kernel.puts("#{message}...")
      else
        Kernel.print("%-60s" % "#{message}:")
        STDOUT.flush
      end
    end

    def report_status(message, color_sym)
      if @configuration[:verbose]
        Kernel.puts(color(message.capitalize, color_sym))
      else
        Kernel.puts("[ #{color(message.upcase, color_sym)} ]")
      end
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