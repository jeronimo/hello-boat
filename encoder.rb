require 'json'
require 'pry'

class Encoder
  attr_accessor :file, :pgns

  def initialize(path = '../canboat/analyzer/pgns.json')
    @file = File.read(File.absolute_path(path))
    @pgns = JSON.parse(file)
  end

  def encode(data)
    @frame = []
    @config = @pgns['PGNs'][data[:pgn].to_s]
    @config['Fields'].each_with_index do |field_config, i|
      name = field_config['Name']
      if value = data[:fields][name.to_sym]
        @frame << Encoder.convert(value, field_config)
      else
        @frame << 'ff'
      end
    end
  end

  def frame
    if @frame.size < @config['Length']
      until @frame.size >= @config['Length']
        @frame << 'ff'
      end
    end
    @frame.join(',')
  end

  def self.convert(value, field_config)
    if field_config['Type'] == 'Lookup table'
      value = field_config['EnumValues'].find {|hash| hash.values.find{|v| v == value}}.keys.first
    end

    value = degrees_to_radians(value) if field_config['Units'] == 'rad'
    value /= field_config['Resolution'].to_f if field_config['Resolution']
    whole_lenth_of_value = (field_config['BitLength'] / 4).to_i # Length defined in binary but needed in hex
    value = "%.#{whole_lenth_of_value}d" % [value] unless value.is_a? String
    if ['rad', 'm/s'].include? field_config['Units']
      value = value.to_i(10).to_s(16) if field_config['Units'] == 'rad'
      value = value.scan(/../).reverse
    end

    if field_config['BitLength'] == 3
      value = "f%s" % [value.to_i(10).to_s(2).to_i(10).to_s(16)]
    end

    value
  end

  def self.degrees_to_radians(value)
    value * Math::PI / 180
  end
end
