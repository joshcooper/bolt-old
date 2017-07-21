require 'slop'
require 'benchmark'

require 'atalanta/thread_pool_executor'
require 'atalanta/em_executor'
require 'ruby-progressbar'

class Atalanta::CLI
  def initialize(argv)
    @argv = argv
    @progress = ProgressBar.create(:format => '%a %B %p%% %t', :autostart => false, :autofinish => false)
  end

  def execute
    opts = Slop.parse(@argv) do |o|
      o.separator 'Commands:'
      o.separator '  <command>'
      o.separator 'Options:'
      o.string '--hosts', 'The hosts file, one host per line'
      o.string '--executor', "The executor type 'async' or 'sync'", default: 'async'
      o.on '-v', '--version', 'print the version' do
        puts Atalanta::VERSION
        exit
      end
      o.on '-h', '--help' do
        puts o
        exit
      end
    end

    unless opts.hosts?
      puts "The --hosts option is required\n\n"
      puts opts
      exit 1
    end

    command = opts.arguments.first
    unless command
      puts "A command must be specified, e.g. 'uname -a'\n\n"
      exit 1
    end

    hosts = get_hosts(opts)
    @progress.total = hosts.length
    @progress.start

    values = nil
    time = Benchmark.realtime do
      case opts[:executor]
      when 'async'
        executor = Atalanta::EMExecutor.new(self)
      when 'sync'
        executor = Atalanta::ThreadPoolExecutor.new(self)
      else
        puts "Unknown executor '#{opts[:executor]}'"
        exit 1
      end

      puts "Executing '#{command}' on #{hosts.length} hosts using #{executor.class}"
      values = executor.execute(hosts, command)
    end

    @progress.finish

    values.each do |value|
      puts value
    end

    puts "\nProcessed #{hosts.length} commands in %.3f secs" % time.to_f
  end

  def get_hosts(opts)
    IO.readlines(opts[:hosts]).map(&:chomp)
  rescue => e
    puts "Failed to parse hosts file: #{opts[:hosts]}: #{e.message}"
    exit 1
  end

  def on_done
    @progress.increment
  end
end
