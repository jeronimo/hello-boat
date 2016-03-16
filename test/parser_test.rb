require 'minitest/autorun'
require './lib/parser'

class TestNMEA0183Parser < Minitest::Test
  def setup
    @rmb_sentence = '$ECRMB,A,0.000,L,001,002,3609.727,N,00522.316,W,0.821,291.359,nan,V*48\r\n'
    @xte_sentence = '$ECXTE,A,A,0.000,L,N*4F\r\n'
    @vdm_sentence = '!AIVDM,1,1,,B,177KQJ5000G?tO`K>RA1wUbN0TKH,0*5C'
  end

  def test_parser_rmb_destination_waypoint_number
    result = NMEA0183::Parser.convert(@rmb_sentence)
    assert_equal '002', result['fields']['destinationWaypointNumber']
  end

  def test_parser_rmb_origin_waypoint_number
    result = NMEA0183::Parser.convert(@rmb_sentence)
    assert_equal '001', result['fields']['originWaypointNumber']
  end

  def test_parser_rmb_destination_latitude
    result = NMEA0183::Parser.convert(@rmb_sentence)
    assert_equal '36.16211666666667', result['fields']['destinationLatitude']
  end

  def test_parser_checksum
    result = NMEA0183::Parser.convert(@rmb_sentence)
    assert_equal 'V*48', result['origin']['checksum']
  end

  def test_rmb_sentense
    result = NMEA0183::Parser.convert(@rmb_sentence)
    assert_equal 1520.492, result['fields']['distanceToWaypoint']
  end

  def test_parser_rmb_bearing_position_to_destination
    result = NMEA0183::Parser.convert(@rmb_sentence)
    assert_equal '291.359', result['fields']['bearingPositionToDestinationWaypoint']
  end

  def test_parser_rmb_bearing_origin_to_destination
    result = NMEA0183::Parser.convert(@rmb_sentence)
    assert_equal '291.359', result['fields']['bearingOriginToDestinationWaypoint']
  end

end
