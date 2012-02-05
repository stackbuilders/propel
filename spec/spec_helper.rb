require "bundler"
Bundler.setup

$:.unshift(File.dirname(__FILE__) + '/../lib')

require 'propel'

require 'stub_shell'

RSpec.configure do |config|
  config.include StubShell::TestHelpers
end

def stub_logger
  double('logger', :report_operation => true, :report_status => true, :puts => true, :warn => true)
end
