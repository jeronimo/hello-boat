require "#{File.dirname(__FILE__)}/conversions"

module NMEA0183
  class Parser
    def self.convert(line)
      if config = NMEA2000::Coversions.config(line)
        variables = line.split(',')
        config['assigned'] = {}
        checksum = variables.pop.gsub(/\\r|\\n/, '')

        config['from_fields'].to_a.each_with_index do |field, key|
          config['assigned'][field[0]] = variables[key + 1] if field[0]
          if field[1]
            if field[1].is_a?(Array)
              field[1].each {|f| config['to_fields'][f] = variables[key + 1]}
            else
              config['to_fields'][field[1]] = variables[key + 1]
            end
          end
        end

        config['assigned']['checksum'] = checksum

        config['calculations'].each do |field, options|
          if config['calculations'][field]
            calculations_variables = config['calculations'][field]['fields'].map do |f|
              config['assigned'][f]
            end
            config['to_fields'][field] = NMEA2000::Coversions.send("#{config['calculations'][field]['method']}", *calculations_variables)
          end
        end if config['calculations']
        {'pgn' => config['to_fields']['pgn'], 'fields' => config['to_fields'], 'origin' => config['assigned'], 'line' => config}
      else
        {'fields' => {}}
      end
    end

  end
end
