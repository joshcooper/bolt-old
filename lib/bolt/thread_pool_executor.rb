require 'concurrent'
require 'bolt/ssh'

class Bolt::ThreadPoolExecutor < Bolt::Executor
  def initialize(observer)
    super
    @pool = Concurrent::FixedThreadPool.new(Concurrent.processor_count * 4)
    @futures = Concurrent::Map.new
  end

  def execute(hosts, command)
    @observer.notify(:start, hosts.length)

    begin
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
        @futures[host] = future
        future.add_observer(self, :on_done)
        future.execute
      end

      wait_for_completion
    ensure
      @observer.notify(:done)
    end
  end

  private

  def on_done(time, value, reason)
    @observer.notify(:increment)
  end

  def wait_for_completion
    @futures.each_pair do |host, future|
      future.wait
    end

    results = []
    @futures.each_pair do |host, future|
      results <<
        if future.value
          "#{host}: #{future.value}"
        else
          "#{host}: #{future.reason}"
        end
    end
    results
  ensure
    @futures.each_pair { |host, future| future.delete_observers }
  end
end
