require 'json'
require 'time'

module NMEA2000
  class Encoder
    attr_accessor :file, :pgns, :config, :pgn, :pgn_config

    def initialize(config)
      @config = config
      @file = File.read(File.absolute_path(config['path_to_pgns_json']))
      @pgns = JSON.parse(file)
    end

    def encode(data)
      @frame = []
      @frame_length = nil
      @byte = ''
      @pgn = data['pgn'].to_s
      @pgn_config = @pgns['PGNs'][@pgn]
      @pgn_config['Fields'].each_with_index do |field_config, i|
        name = field_config['Id']
        # Short codes
        if Encoder.shorter_than_byte_and_lookup?(field_config)
          @byte += Encoder.get_lookup_field(name, data, field_config)

          if @byte.length == 8 || @pgn_config['Fields'][i+1].nil? || @pgn_config['Fields'][i+1]['BitLength'] >= 8
            @byte = @byte.to_i(10).to_s(16)
            @byte = "0#{@byte}" if @byte.length == 1
            @frame << @byte
            @byte = ''
          end
          next
        end

        # All >= 8 bit
        if value = data['fields'][name]
          if value.to_s.match(/[a-zA-Z]/) || value.to_s.empty?
            @frame << Encoder.convert_to_blank(field_config)
          else
            @frame << Encoder.convert(value, field_config)
          end
        else # Default ff for blanks
          @frame << Encoder.convert_to_blank(field_config)
        end
      end
    end

    def frame_length
      @frame_length ||= @pgn_config['Length'] #> 8 ? @pgn_config['Length'] : 8
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
      "#{Time.now.utc.xmlschema(3)},3,#{@pgn},1,255,#{frame_length},#{frame}"
    end

    class << self
      def shorter_than_byte_and_lookup?(field_config)
        field_config['BitLength'] < 8 && (field_config['Type'] == 'Lookup table' || field_config['Type'] == 'Binary data')
      end

      def get_lookup_field(name, data, field_config)
        if value = data['fields'][name]
          value = field_config['EnumValues'].find {|hash| hash.values.find{|v| v == value}}.keys.first
          value = Encoder.convert_to_binary(value, field_config)
          value = "0#{value}" if value.length == 1
          value
        else
          "%0.#{field_config['BitLength']}d" % '00'
        end
      end

      def convert_to_blank(field_config)
        bytes_count = field_config['BitLength'] > 8 ? field_config['BitLength'] / 8 : 1
        ['ff'] * bytes_count
      end

      def convert(value, field_config)
        original = value

        # Sid
        if value && field_config['Id'] == 'sid'
          value = value.to_s.to_i(10).to_s(16)
          value = "%.2s" % value
          value = "0#{value}" if value.length == 1
        end

        if field_config['Units'] == 'rad'
          value = degrees_to_radians(value)
        end

        if field_config['Resolution']
          value = (value.to_f / field_config['Resolution'].to_f).round
        end

        whole_lenth_of_value = (field_config['BitLength'] / 4).to_i # Length defined in binary but needed in hex

        if !value.is_a?(String)
          value = "%.#{whole_lenth_of_value}d" % [value]
        end

        if ['rad', 'm/s', 'm', 'deg', 'K'].include? field_config['Units']
          if convert_to_hex?(field_config)
            value = convert_to_hex(value, field_config)
            value.gsub!('..', '') if value.match('..f')
            if whole_lenth_of_value > value.length
              until whole_lenth_of_value <= value.length
                value = "0#{value}"
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
        ['rad', 'm', 'deg', 'K'].include? field_config['Units']
      end

      def convert_to_hex(value, field_config)
        "%x" % value.to_s.to_i if convert_to_hex?(field_config)
      end

      def convert_to_binary(value, field_config)
        "%0.#{field_config['BitLength']}d" % value.to_s.to_i(10).to_s(2)
      end

      def degrees_to_radians(value)
        value.to_f * Math::PI / 180.to_f
      end

    end
  end
end
