require 'socket'

class Client
  def initialize
    @server = TCPSocket.open('10.0.0.1', 5000)
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
      end
    end
  end

  def send(msg)
    @request = Thread.new do
      puts "Client -> #{msg}"
      @server.puts( msg )
    end
  end
end

