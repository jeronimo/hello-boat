require 'yaml'
require "#{File.dirname(__FILE__)}/lib/encoder"
require "#{File.dirname(__FILE__)}/lib/client"
require "#{File.dirname(__FILE__)}/lib/conversions"

config = YAML.load_file("#{File.dirname(__FILE__)}/config.yml")

encoder = NMEA2000::Encoder.new(config)


1000.times do
  client = NMEA2000::Client.new(config)

  encoder.encode({'pgn' => 130310, "fields" => {"waterTemperature" => NMEA2000::Conversions.celcius_to_kalvin(16.3)}})
  p encoder.full_sentence
  client.send(encoder.full_sentence)

  encoder.encode({'pgn' => 130311, "fields" => {"temperatureSource" => "Sea Temperature", "temperature" => NMEA2000::Conversions.celcius_to_kalvin(16.3)}})
  p encoder.full_sentence
  client.send(encoder.full_sentence)
  sleep 1
end

