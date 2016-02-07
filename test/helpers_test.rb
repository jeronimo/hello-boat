require 'minitest/autorun'
require './helpers'

class TestNMEA2000Coversions < Minitest::Test
  def setup
    @rmb_sentence = '$ECRMB,A,0.000,L,001,002,3609.727,N,00522.316,W,0.821,291.359,nan,V*48\r\n'
    @xte_sentence = '$ECXTE,A,A,0.000,L,N*4F\r\n'
    @vdm_sentence = '!AIVDM,1,1,,B,177KQJ5000G?tO`K>RA1wUbN0TKH,0*5C'

    NMEA2000::Coversions.init
  end

  def test_coordinate_to_decimals_for_west
    assert_equal "-5.371933333333334", NMEA2000::Coversions.coordinate_to_decimals('00522.316','W')
  end

  def test_coordinate_to_decimals_for_north
    assert_equal "36.16211666666667", NMEA2000::Coversions.coordinate_to_decimals('3609.727', 'N')
  end

  def test_get_sentence_name_for_rmb
    assert_equal 'RMB', NMEA2000::Coversions.get_sentence_name(@rmb_sentence)
  end

  def test_get_sentence_name_for_vdm
    assert_equal 'VDM', NMEA2000::Coversions.get_sentence_name(@vdm_sentence)
  end

  def test_conversions_config_by_sentence_skip
    config = NMEA2000::Coversions.config(@vdm_sentence)
    assert_equal config, nil
  end

  def test_conversions_config_by_sentence
    config = NMEA2000::Coversions.config(@rmb_sentence)
    assert_equal 129284, config['to_fields']['pgn']
  end

  def test_parser_rmb_destination_waypoint_number
    result = NMEA0183::Parser.convert(@rmb_sentence)
    assert_equal '001', result['fields']['destinationWaypointNumber']
  end

  def test_parser_rmb_origin_waypoint_number
    result = NMEA0183::Parser.convert(@rmb_sentence)
    assert_equal '002', result['fields']['originWaypointNumber']
  end

  def test_parser_rmb_destination_latitude
    result = NMEA0183::Parser.convert(@rmb_sentence)
    assert_equal '36.16211666666667', result['fields']['destinationLatitude']
  end

  def test_parser_checksum
    result = NMEA0183::Parser.convert(@rmb_sentence)
    assert_equal 'V*48', result['origin']['checksum']
  end

  def test_rmb_sentece
    result = NMEA0183::Parser.convert(@rmb_sentence)
    assert_equal "0.821", result['fields']['distanceToWaypoint']
  end

end
