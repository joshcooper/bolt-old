require 'slop'

require 'atalanta/executor'
require 'ruby-progressbar'

class Atalanta::CLI
  def initialize(argv)
    @argv = argv
    @progress = ProgressBar.create(:format => '%a %B %p%% %t', :autostart => false, :autofinish => false)
  end

  def execute
    opts = Slop.parse(@argv) do |o|
      o.separator 'Commands:'
      o.separator ''
      o.separator 'Options:'
      o.string '--hosts', 'hosts file, one host per line'
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

    executor = Atalanta::Executor.new(self)
    begin
      hosts = IO.readlines(opts[:hosts])
      @progress.total = hosts.length
      @progress.start
      puts "Processing #{hosts.length} hosts"
      hosts.each do |host|
        executor.async_execute(host.chomp!, 'hostname')
      end
    rescue => e
      puts "Failed to parse hosts file: #{opts[:hosts]}: #{e.message}"
      exit 1
    end

    values = executor.wait_for_completion

    @progress.finish

    values.each do |value|
      puts value
    end
  end

  def on_done(time, value, reason)
    @progress.increment
  end
end
