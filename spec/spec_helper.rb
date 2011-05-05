require "bundler"
Bundler.setup

$:.unshift(File.dirname(__FILE__) + '/../lib')

require 'propel'

def stub_logger
  double('logger', :report_operation => true, :report_status => true, :puts => true, :warn => true)
end
