require 'socket'
require 'pry'

# New instance needs to be created everytime NMEA0183::Server receives new message (Not sure why it is like that)
module NMEA2000
  class Client
    attr_accessor :config
    def initialize(config)
      @config = config
      @server = TCPSocket.new(config['client']['host'], config['client']['port'])
      puts "Client initilize #{config['client']['host']}:#{config['client']['port']}"
    end

    def send(message)
      Thread.new do
        @server.puts(message)
        puts "Client #{Time.now} < #{message}"
      end
    end
  end
end
