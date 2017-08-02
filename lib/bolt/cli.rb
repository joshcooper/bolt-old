require 'slop'
require 'benchmark'

require 'bolt/executor'
require 'bolt/ui'
require 'ruby-progressbar'

class Bolt::CLI
  def initialize(argv, ui = Bolt::UI.new)
    @argv = argv
    @ui = ui
  end

  def execute
    opts = Slop.parse(@argv, suppress_errors: true) do |o|
      o.separator 'Commands:'
      o.separator '  <command>'
      o.separator 'Options:'
      o.string '--hosts', 'The hosts file, one host per line'
      o.string '--executor', "The executor type 'async' or 'sync'", default: 'async'
      o.on '-v', '--version', 'print the version' do
        puts Bolt::VERSION
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

    command = opts.arguments
    if command && !command.empty?
      command = command.join(' ')
    else
      puts "A command must be specified, e.g. 'uname -a'\n\n"
      puts opts
      exit 1
    end

    hosts = get_hosts(opts)
    values = nil
    time = Benchmark.realtime do
      executor = Bolt::Executor.create(opts[:executor], @ui)
      if executor
        puts "Executing '#{command}' on #{hosts.length} hosts using #{executor.class}\n\n"
        values = executor.execute(hosts, command)
      else
        puts "Unknown executor '#{opts[:executor]}"
        exit 1
      end
    end

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
end
