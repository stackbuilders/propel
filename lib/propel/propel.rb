module Propel
  class Propel
    def initialize(repository, rebase)
      @repository = repository
      @rebase     = rebase
    end

    def start
      @repository.pull(@rebase) && rake && @repository.push
    end

    private
    def rake
      system('rake')
    end
  end
end