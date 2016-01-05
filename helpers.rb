require 'pry'
require 'yaml'

class Coversions
  class << self
    def load
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

class Parser
  class << self
    def parse(line)
      if config = Coversions.config(line)
        variables = line.split(',')
        config['assigned'] = {}
        config['from_fields'].to_a.each_with_index do |field, key|
          if field && field[0]
            config['assigned'][field[0]] = variables[key + 1]
          end
        end

        config['from_fields'].to_a.each_with_index do |field, key|
          if field[1]
            config['to_fields'][field[1]] = variables[key + 1]
          end
        end

        config['calculations'].each do |field, options|
          if config['calculations'][field]
            calculations_variables = config['calculations'][field]['fields'].map do |f|
              config['assigned'][f]
            end
            config['to_fields'][field] = Coversions.send("#{config['calculations'][field]['method']}", *calculations_variables)
          end
        end
        {'fields' => config['to_fields']}
      else
        {'fields' => {}}
      end
    end
  end
end
