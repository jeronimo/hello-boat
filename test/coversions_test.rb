require 'minitest/autorun'
require './lib/conversions'

class TestNMEA2000Conversions < Minitest::Test
  def setup
    @rmb_sentence = '$ECRMB,A,0.000,L,001,002,3609.727,N,00522.316,W,0.821,291.359,nan,V*48\r\n'
    @xte_sentence = '$ECXTE,A,A,0.000,L,N*4F\r\n'
    @vdm_sentence = '!AIVDM,1,1,,B,177KQJ5000G?tO`K>RA1wUbN0TKH,0*5C'

    NMEA2000::Conversions.init
  end

  def test_coordinate_to_decimals_for_west
    assert_equal "-5.371933333333334", NMEA2000::Conversions.coordinate_to_decimals('00522.316','W')
  end

  def test_coordinate_to_decimals_for_west_2
    assert_equal "-5.37075", NMEA2000::Conversions.coordinate_to_decimals('00522.245','W')
  end

  def test_coordinate_to_decimals_for_north
    assert_equal "36.16211666666667", NMEA2000::Conversions.coordinate_to_decimals('3609.727', 'N')
  end

  def test_nautical_miles_to_meters
    assert_equal 1852.0, NMEA2000::Conversions.nautical_miles_to_meters(1)
  end

  def test_get_sentence_name_for_rmb
    assert_equal 'RMB', NMEA2000::Conversions.get_sentence_name(@rmb_sentence)
  end

  def test_get_sentence_name_for_vdm
    assert_equal 'VDM', NMEA2000::Conversions.get_sentence_name(@vdm_sentence)
  end

  def test_conversions_config_by_sentence_skip
    config = NMEA2000::Conversions.config(@vdm_sentence)
    assert_equal config, nil
  end

  def test_conversions_config_by_sentence
    config = NMEA2000::Conversions.config(@rmb_sentence)
    assert_equal 129284, config['to_fields']['pgn']
  end
end
