require 'minitest/autorun'
require './encoder'

class TestEncoder < Minitest::Test
  def setup
    @encoder = Encoder.new
  end

  def test_file_load
    assert_equal 'Canboat NMEA2000 Analyzer', @encoder.pgns['CreatorCode']
  end

  def test_encoding_wind_data
    @encoder.encode({pgn: 130306, "fields":{"Wind Speed": 0.08,"Wind Angle": 104.9,"Reference": "True (boat referenced)"}})
    # original 'ff,08,00,7d,47,fb,ff,ff'
    assert_equal 'ff,08,00,84,47,fb,ff,ff', @encoder.frame
  end
end
