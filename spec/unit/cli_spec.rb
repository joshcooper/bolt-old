require 'spec_helper'
require 'bolt/cli'

describe Bolt::CLI do
  it "prints the version and exits" do
    %w[-v --version].each do |arg|
      cli = Bolt::CLI.new([arg])
      expect {
        cli.execute
      }.to have_printed(/0.1.0/).and_exit_with(0)
    end
  end

  it "prints help and exits" do
    %w[-h --help].each do |arg|
      cli = Bolt::CLI.new([arg])
      expect {
        cli.execute
      }.to have_printed(/^usage/).and_exit_with(0)
    end
  end

  context "hosts file" do
    let(:hosts) { %w[host1 host2 host3] }

    it "parses a hosts file" do
      allow(IO).to receive(:readlines).and_call_original
      expect(IO).to receive(:readlines).with('myhosts.txt').and_return(hosts)

      expect {
        cli = Bolt::CLI.new(%w[--hosts myhosts.txt])
        cli.execute
      }.to have_printed(/Processing 3 hosts/)
    end

    it "exits with 1 if the hosts file is not specified" do
      expect {
        cli = Bolt::CLI.new([])
        cli.execute
      }.to have_printed(/^The --hosts option is required/).and_exit_with(1)
    end

    it "exits with 1 if the hosts file doesn't exist" do
      allow(IO).to receive(:readlines).and_call_original
      expect(IO).to receive(:readlines).with('myhosts.txt').and_raise(Errno::ENOENT, "No such file or directory @ rb_sysopen - myhosts.txt")

      expect {
        cli = Bolt::CLI.new(%w[--hosts myhosts.txt])
        cli.execute
      }.to have_printed(/Failed to parse hosts file/).and_exit_with(1)
    end
  end
end
