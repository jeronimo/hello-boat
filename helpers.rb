require 'pry'
require 'yaml'

class Coversions
  class << self
    def load
      @conversions = YAML.load_file('/Users/julius/work/sailing/send_to_boat/conversion.yml')
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

class Parser
  class << self
    def get_the_name(line)
      @all_variables = line.split(',')
    end

    def parse(line)
      if config = Coversions.config(line)
        variables = line.split(',')

        config['from_fields'].to_a.each_with_index do |data, key|
          if data[1]
            config['to_fields'][data[1]] = variables[key + 1]
          end
        end
        {'fields' => config['to_fields']}
      else
        {'fields' => {}}
      end
    end
  end
end
