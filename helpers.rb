require 'pry'
require 'yaml'

require './encoder'

module NMEA2000
  class Coversions
    class << self
      def init
        @conversions = YAML.load_file(File.absolute_path('conversion.yml'))
      end

      def conversions
        @conversions
      end

      def get_sentence_name(line)
        line.split(',')[0][/([A-Z]){3}$/]
      end

      def config(line)
        conversions[get_sentence_name(line).downcase] rescue nil
      end

      def coordinate_to_decimals(coordinate, hemisphere = 'N')
        digrees = coordinate[/^(.*)\d\d\./, 1]
        tenths_and_hundreds = coordinate[/(\d\d\..*)/, 1].to_f / 60
        "#{['W', 'S'].include?(hemisphere) ? '-' : ''}#{digrees.to_i + tenths_and_hundreds}"
      end
    end
  end
end

module NMEA0183
  class Parser
    def self.convert(line)
      if config = NMEA2000::Coversions.config(line)
        variables = line.split(',')
        config['assigned'] = {}
        checksum = variables.pop.gsub(/\\r|\\n/, '')

        config['from_fields'].to_a.each_with_index do |field, key|
          config['assigned'][field[0]] = variables[key + 1] if field[0]
          config['to_fields'][field[1]] = variables[key + 1] if field[1]
        end
        config['assigned']['checksum'] = checksum

        config['calculations'].each do |field, options|
          if config['calculations'][field]
            calculations_variables = config['calculations'][field]['fields'].map do |f|
              config['assigned'][f]
            end
            config['to_fields'][field] = NMEA2000::Coversions.send("#{config['calculations'][field]['method']}", *calculations_variables)
          end
        end
        {'pgn' => config['to_fields']['pgn'], 'fields' => config['to_fields'], 'origin' => config['assigned'], 'line' => config}
      else
        {'fields' => {}}
      end
    end

  end
end
