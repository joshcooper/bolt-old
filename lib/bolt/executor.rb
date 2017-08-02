class Bolt::Executor
  def self.create(name, observer)
    case name
    when 'async'
      Bolt::EMExecutor.new(observer)
    when 'sync'
      Bolt::ThreadPoolExecutor.new(observer)
    else
      nil
    end
  end

  def initialize(observer)
    @observer = observer
  end

  def execute(hosts, command)
    raise NotImplementedError
  end
end

require 'bolt/em_executor'
require 'bolt/thread_pool_executor'
