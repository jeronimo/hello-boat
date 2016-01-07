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
    config = @pgns['PGNs'][data[:pgn].to_s]
    config['Fields'].each_with_index do |field, i|
      name = field['Name']
      if value = data[:fields][name.to_sym]
        @frame << Encoder.convert(value, field)
      else
        @frame << 'ff'
      end
    end
  end

  def frame
    @frame.join(',')
  end

  def self.convert(value, config)
    value = degrees_to_radians(value) if config['Units'] == 'rad'
    value /= config['Resolution'].to_f if config['Resolution']
    whole_lenth_of_value = (config['BitLength'] / 4).to_i # Length defined in binary but needed in hex
    value = "%.#{whole_lenth_of_value}d" % [value] unless value.is_a? String
    if ['rad', 'm/s'].include? config['Units']
      value = value.to_i(10).to_s(16) if config['Units'] == 'rad'
      value = value.scan(/../).reverse

    end

    # end
    value
  end

  def self.degrees_to_radians(value)
    value * Math::PI / 180
  end
end
