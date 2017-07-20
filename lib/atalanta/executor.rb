require 'concurrent'
require 'atalanta/ssh'

class Atalanta::Executor
  def initialize(observer)
    @pool = Concurrent::FixedThreadPool.new(Concurrent.processor_count * 4)
    @queue = Concurrent::Array.new
    @observer = observer
  end

  def async_execute(host, command)
    future = Concurrent::Future.new(:executor => @executor) do
      ssh = Atalanta::SSH.new(host, 'root')
      ssh.connect
      begin
        output = ssh.execute(command)
      ensure
        ssh.disconnect
      end
      output
    end
    @queue << future
    future.add_observer(@observer, :on_done)
    future.execute
  end

  def wait_for_completion
    @queue.each do |future|
      future.wait
    end

    @queue.map do |future|
      future.value || "Error: #{future.reason}"
    end
  ensure
    @queue.each { |future| future.delete_observers }
  end
end
