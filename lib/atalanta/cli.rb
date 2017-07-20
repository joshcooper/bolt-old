require 'slop'

class Atalanta::CLI
  def initialize(argv)
    @argv = argv
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

    begin
      hosts = IO.readlines(opts[:hosts])
      puts "Processing #{hosts.length} hosts"
      hosts.each do |host|
        # do something
      end
    rescue => e
      puts "Failed to parse hosts file: #{opts[:hosts]}"
      exit 1
    end
  end
end
