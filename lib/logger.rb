require 'json'
require 'time'
require 'socket'

module NMEA2000
  class Logger
    attr_accessor :config, :filter

    def initialize(config, filter)
      @config = config
      @filter = filter
    end

    def connect
      @logger = TCPSocket.new(config['logger']['host'], config['logger']['port'])
      puts "Logger - initilize #{Time.now.to_s} #{config['logger']['host']}:#{config['logger']['port']}"
    end

    def output
      while line = @logger.gets
        next if filter['pgn'].include? JSON.parse(line)["pgn"]
        puts line
      end
      puts "Logger - no output anymore"
      run
    end

    def run
      begin
        connect
        output
      rescue Errno::ECONNREFUSED => e
        puts e
        sleep 5
        run
      end
    end
  end
end

