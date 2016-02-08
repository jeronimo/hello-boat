require 'socket'
require 'pry'

module NMEA2000
  class Client
    def initialize
      @server = TCPSocket.new('10.0.0.1', 5000)
      @request = nil
      @response = nil
      #listen
      #@request.join
      #@response.join
    end

    def listen
      @response = Thread.new do
        loop do
          msg = @server.gets.chomp
          puts "Client <- #{msg}"
        end
      end
    end

    def send(msg)
      Thread.new do
        @server.puts( msg )
        puts "Client ->>> #{msg}"
      end
    end
  end
end
