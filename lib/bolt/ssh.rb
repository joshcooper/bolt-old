require 'net/ssh'

class Bolt::SSH
  def initialize(host, user)
    @host = host
    @user = user
    @options = {
      :auth_methods => ['publickey'],
      :host_key     => 'ssh-rsa',
      :keys         => ['~/.ssh/jenkins'],
      :verbose      => :warn #:info
    }
  end

  def connect
    @conn = Net::SSH.start(@host, @user, @options)
  end

  def execute(command)
    @conn.exec!(command)
  end

  def disconnect
    @conn.close unless @conn.closed?
  end
end
