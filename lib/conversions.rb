require 'yaml'

module NMEA2000
  class Conversions
    class << self
      def init
        @conversions = YAML.load_file("#{File.dirname(__FILE__)}/../conversion.yml")
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

      def nautical_miles_to_meters(nm)
        nm.to_f * 1852.0
      end

      def celcius_to_kalvin(temperature)
        temperature + 273.15
      end
    end
  end
end
