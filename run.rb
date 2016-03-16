require 'yaml'
require './server'

config = YAML.load_file('config.yml')

server = NMEA0183::Server.new(config)
server.run
