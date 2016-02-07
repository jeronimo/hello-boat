require 'json'
require 'time'
require 'pry'

module NMEA2000
  class Encoder
    attr_accessor :file, :pgns, :config, :pgn

    def initialize(path = '../canboat/analyzer/pgns.json')
      @file = File.read(File.absolute_path(path))
      @pgns = JSON.parse(file)
    end

    def encode(data)
      @frame = []
      @byte = ''
      @pgn = data['pgn'].to_s
      @config = @pgns['PGNs'][@pgn]
      @config['Fields'].each_with_index do |field_config, i|
        name = field_config['Id']

        # Short codes
        if field_config['BitLength'] < 8 && field_config['Type'] == 'Lookup table'
          if value = data['fields'][name]
            value = field_config['EnumValues'].find {|hash| hash.values.find{|v| v == value}}.keys.first
            value = "%.2s" % value.to_i(10).to_s(2)
            value = "0#{value}" if value.length == 1
            @byte += value
          else
            @byte += '00'
          end

          if @byte.length == 8 || @config['Fields'][i+1].nil? || @config['Fields'][i+1]['BitLength'] >= 8
            @byte = @byte.to_i(10).to_s(16)
            @byte = "0#{@byte}" if @byte.length == 1
            @frame << @byte
            @byte = ''
          end
          next
        end

        # All >= 8 bit
        if value = data['fields'][name]
          if value.to_s.match(/[a-zA-Z]/)
            convert_to_blank(field_config)
          else
            @frame << Encoder.convert(value, field_config)
          end
        else # Default ff for blanks
          convert_to_blank(field_config)
        end
      end
    end

    def convert_to_blank(field_config)
      bytes_count = field_config['BitLength'] > 8 ? field_config['BitLength'] / 8 : 1
      @frame << ['ff'] * bytes_count
    end

    def frame_length
      @frame_length ||= @config['Length'] > 8 ? @config['Length'] : 8
    end

    def frame

      if @frame.flatten.size < frame_length
        until @frame.flatten.size >= frame_length
          @frame << 'ff'
        end
      end
      @frame.join(',')
    end

    def full_sentence
      "#{Time.now.utc.xmlschema(3)},2,#{@pgn},,255,#{frame_length},#{frame}"
    end

    class << self

      def convert(value, field_config)
        original = value

        if value && field_config['Id'] == 'sid'
          value = value.to_s.to_i(10).to_s(16)
        end

        value = degrees_to_radians(value) if field_config['Units'] == 'rad'
        if field_config['Resolution']
          value = (value.to_f / field_config['Resolution'].to_f).round
        end

        whole_lenth_of_value = (field_config['BitLength'] / 4).to_i # Length defined in binary but needed in hex
        value = "%.#{whole_lenth_of_value}d" % [value] unless value.is_a? String
        if ['rad', 'm/s', 'm', 'deg'].include? field_config['Units']
          if convert_to_hex?(field_config)
            value = value.to_i * -1 + 90 if value.to_i < 0 && field_config['Type'] == 'Latitude'
            value = value.to_i * -1 + 180 if value.to_i < 0 && field_config['Type'] == 'Longitude'
            value = convert_to_hex(value, field_config)

            if whole_lenth_of_value > value.length
              until whole_lenth_of_value <= value.length
                value = "00#{value}"
              end
            end
          end
          value = value.scan(/../).reverse
        end

        if value.length > 2 && field_config['Units'].nil?
          value = value[-2..-1]
          if whole_lenth_of_value > value.length
            until whole_lenth_of_value <= value.length
              value = "00#{value}"
            end
          end
          value = value.scan(/../).reverse
        end
        value
      end

      def convert_to_hex?(field_config)
        ['rad', 'm', 'deg'].include? field_config['Units']
      end

      def convert_to_hex(value, field_config)
        value.to_s.to_i(10).to_s(16) if convert_to_hex?(field_config)
      end

      def to_distance(value, field_config)

      end

      def degrees_to_radians(value)
        value.to_f * Math::PI / 180.to_f
      end

    end
  end
end
