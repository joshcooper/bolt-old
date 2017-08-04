# Bolt

Bolt is a ruby command-line tool for executing commands and scripts on remote
systems using ssh and winrm.

## Goals

* Execute commands on remote *nix and Windows systems
* Distribute and execute scripts, e.g. bash, powershell, python
* Scale to upwards of 1000 concurrent connections
* Support industry standard protocols (ssh/scp, winrm/psrp) and authentication
  methods (password, publickey)

## Supported Platforms

* Linux, OSX, Windows
* Ruby 2.3+

## Installation

    $ gem install bolt

## Usage

Execute a command:

    $ bolt exec --nodes harpo zeppo command='whereami'
    harpo: /dev/pts/0 /root harpo 10.32.118.6
    zeppo: /dev/pts/0 /root zeppo 10.32.115.201


## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/joshcooper/bolt.


## License

The gem is available as open source under the terms of the [Apache 2.0](https://www.apache.org/licenses/LICENSE-2.0).

