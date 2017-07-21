require 'eventmachine'
require 'em-ssh'

class Bolt::EMExecutor
  trap(:INT) { EM.stop }
  trap(:TERM){ EM.stop }

  OPTIONS = {
    :auth_methods => ['publickey'],
    :host_key     => 'ssh-rsa',
    :keys         => ['~/.ssh/jenkins'],
    :verbose      => :warn
  }

  def initialize(observer)
    @observer = observer
    @results = []
  end

  def execute(hosts, command)
    EM.run do
      done = 0
      check = lambda do
        @observer.on_done
        done += 1
        if done >= hosts.length
          # closes all connections
          EM.stop
        end
      end

      conns = {}
      hosts.each do |host|
        connection = conns[host]
        unless connection
          connection = EM::Ssh.start(host, 'root', OPTIONS)
          conns[host] = connection
        end

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
  end
end