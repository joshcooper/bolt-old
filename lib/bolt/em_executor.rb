require 'eventmachine'
require 'em-ssh'

class Bolt::EMExecutor < Bolt::Executor
  trap(:INT) { EM.stop }
  trap(:TERM){ EM.stop }

  # REMIND: we're not configuring host key verification
  OPTIONS = {
    :auth_methods => ['publickey'],
    :host_key     => 'ssh-rsa',
    :keys         => ['~/.ssh/jenkins'],
    :verbose      => :warn
  }

  def initialize(observer)
    super
    @results = []
  end

  def execute(hosts, command)
    @observer.notify(:start, hosts.length)

    begin
      EM.run do
        done = 0
        check = lambda do
          @observer.notify(:increment)
          done += 1
          if done >= hosts.length
            # closes all connections
            EM.stop
          end
        end

        hosts.each do |host|
          connection = EM::Ssh.start(host, 'root', OPTIONS)

          # are we overwriting the old errback/callback, or are we appending
          connection.errback do |err|
            @results << "#{host}: #{err} (#{err.class})"
            check[]
          end
          connection.callback do |ssh|
            @results << "#{host}: #{ssh.exec!(command)}"
            check[]
          end
        end
      end

      @results
    ensure
      @observer.notify(:done)
    end
  end
end
