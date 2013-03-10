$:.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'test_helper'
require 'tools/repl_set_manager'

class Test::Unit::TestCase
  def shared_repl_set
    @@rs ||= begin
              rs = ReplSetManager.new
              rs.start_set
              rs
             end
  end

  # Generic code for rescuing connection failures and retrying operations.
  # This could be combined with some timeout functionality.
  def rescue_connection_failure(max_retries=30)
    retries = 0
    begin
      yield
    rescue Mongo::ConnectionFailure => ex
      puts "Rescue attempt #{retries}: from #{ex}"
      retries += 1
      raise ex if retries > max_retries
      sleep(2)
      retry
    end
  end
  
  def build_seeds(num_hosts)
    seeds = []
    num_hosts.times do |n|
      seeds << "#{shared_repl_set.host}:#{shared_repl_set.ports[n]}"
    end
    seeds
  end
end
