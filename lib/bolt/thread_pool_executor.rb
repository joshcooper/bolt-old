require 'concurrent'
require 'bolt/ssh'

class Bolt::ThreadPoolExecutor
  def initialize(observer)
    @pool = Concurrent::FixedThreadPool.new(Concurrent.processor_count * 4)
    @queue = Concurrent::Array.new
    @observer = observer
  end

  def execute(hosts, command)
    hosts.each do |host|
      future = Concurrent::Future.new(:executor => @executor) do
        ssh = Bolt::SSH.new(host, 'root')
        ssh.connect
        begin
          output = ssh.execute(command)
        ensure
          ssh.disconnect
        end
        output
      end
      @queue << future
      future.add_observer(self, :on_done)
      future.execute
    end

    wait_for_completion
  end

  private

  def on_done(time, value, reason)
    @observer.on_done
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
