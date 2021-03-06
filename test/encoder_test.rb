require 'minitest/autorun'
require './lib/encoder'

class TestNMEA2000Encoder < Minitest::Test
  def setup
    @encoder = NMEA2000::Encoder.new({'path_to_pgns_json' => '../canboat/analyzer/pgns.json'})
  end

  def test_file_load
    assert_equal 'Canboat NMEA2000 Analyzer', @encoder.pgns['CreatorCode']
  end

  def test_encoding_wind_data
    @encoder.encode({'pgn' => 130306, "fields" => {"windSpeed" => 0.08,"windAngle" => 104.9,"reference" => "True (boat referenced)"}})
    assert_equal 'ff,08,00,85,47,0b', @encoder.frame
  end

  def test_encoding_navigation_data
    # "bearingPositionToDestinationWaypoint"=>"291.359" - not sure if this one is correct
    @encoder.encode({'pgn' => 129284, "fields" => {"distanceToWaypoint"=>"0.821", "destinationWaypointNumber"=>"001", "originWaypointNumber"=>"", "destinationLatitude"=>"36.16211666666667", "destinationLongitude"=>"00522.316", "waypointClosingVelocity"=>"nan"}})
    assert_equal 'ff,52,00,00,00,00,ff,ff,ff,ff,ff,ff,ff,ff,ff,ff,ff,ff,ff,ff,01,00,00,00,af,e6,8d,15,8c,31,75,13,ff,ff', @encoder.frame
  end

  def test_encoding_navigation_data_by_example
    # "bearingPositionToDestinationWaypoint"=>"358.471" - not sure if this one is correct
    # Found example - 10,a6,ba,00,00,00,ff,ff,ff,ff,ff,ff,ff,ff,65,f4,01,00,00,00,ff,ff,ff,ff,1a,b3,0c,1c,b4,71,bf,b6,00,00'
    @encoder.encode({'pgn' => 129284, "fields" => {"sid" => 16,"distanceToWaypoint"=>"477.82", "courseBearingReference" => "True", "bearingPositionToDestinationWaypoint"=>"358.471", "originWaypointNumber"=>"001", "destinationWaypointNumber"=>"swanto", "destinationLatitude"=>"47.0594330", "destinationLongitude"=>"-122.8967500", "waypointClosingVelocity"=>"0"}})
    assert_equal '10,a6,ba,00,00,00,ff,ff,ff,ff,ff,ff,ff,ff,65,f4,01,00,00,00,ff,ff,ff,ff,1a,b3,0c,1c,1b,f7,6b,fb,00,00', @encoder.frame
  end

  def test_encoding_cross_track
    @encoder.encode({"pgn"=>129283, "fields" => {"sid"=>"01", "xteMode"=>nil, "reserved"=>nil, "navigationTerminated"=>nil, "xte"=>"0.000"}})
    assert_equal '01,00,00,00,00,00', @encoder.frame
  end

  def test_convert_meter_units
    assert_equal ["e8", "03", "00", "00"], NMEA2000::Encoder.convert(10, {'Units' => 'm', 'Resolution' => '0.01', 'BitLength' => 32})
  end

  def test_covert_degrees_to_radians
    assert_equal ["b8", "7a"], NMEA2000::Encoder.convert(180, {'Units' => 'rad', 'Resolution' => '0.0001', 'BitLength' => 16})
  end

  def test_covert_degrees
    assert_equal ["00", "e9", "a4", "35"], NMEA2000::Encoder.convert(90, {'Units' => 'deg', 'Resolution' => '0.0000001', 'BitLength' => 32})
  end

  def test_covert_negative_degrees
    assert_equal ["70", "b1", "a5", "fc"], NMEA2000::Encoder.convert(-90, {'Units' => 'deg', 'Resolution' => '0.0000001', 'BitLength' => 32})
  end

  def test_covert_speed_units
    assert_equal ["00", "10"], NMEA2000::Encoder.convert(10, {'Units' => 'm/s', 'Resolution' => '0.01', 'BitLength' => 16})
  end

  def test_shorter_than_byte_cut
    assert_equal ["34"], NMEA2000::Encoder.convert(1234, {'BitLength' => 2})
  end

  def test_to_binary_conversion
    assert_equal "101", NMEA2000::Encoder.convert_to_binary(5, {'BitLength' => 3})
    # it still does more than than BitLength, maybe it is ok
    assert_equal "101", NMEA2000::Encoder.convert_to_binary(5, {'BitLength' => 1})
  end

  def test_shorter_than_byte_and_lookup?
    assert_equal true, NMEA2000::Encoder.shorter_than_byte_and_lookup?({'BitLength' => 5, 'Type' => 'Lookup table'})
    assert_equal true, NMEA2000::Encoder.shorter_than_byte_and_lookup?({'BitLength' => 5, 'Type' => 'Binary data'})
  end

  def test_empty_get_lookup_field
    assert_equal "0000", NMEA2000::Encoder.get_lookup_field('field_name', {'fields' => {}}, {'BitLength' => 4, 'Type' => 'Lookup table', 'EnumValues' => {}})
    assert_equal "0", NMEA2000::Encoder.get_lookup_field('field_name', {'fields' => {}}, {'BitLength' => 1, 'Type' => 'Lookup table', 'EnumValues' => {}})
  end

  def test_present_get_lookup_field
    assert_equal "01000", NMEA2000::Encoder.get_lookup_field('field', {'fields' => {'field' => 'Some value'}}, {'BitLength' => 5, 'Type' => 'Lookup table', 'EnumValues' => [{'8' => 'Some value'}]})
  end
end


# PGN: 129284 (0x1F904), SRC = 0, DST = 255, Priority = 3, Len = 34, Data = 10 A6 BA 00 00 C0 FF FF FF FF FF FF FF FF 65 F4 01 00 00 00 FF FF FF FF 1A B3 0C 1C B4 71 BF B6 00 00

# Full decoded Message
# NMEA 2000 PGN: 129284 (0x1F904)
# Name: Navigation Data
# Source = 0, Destination = 255
# Priority = 3, Length = 34
# Number Of Fields = 15
# Field 1: SID = 16
# Field 2: Distance to Destination Waypoint = 477.82 Metres
# Field 3: Course/Bearing Ref. = 0 (Direction Reference True)
# Field 4: Perpendicular Crossed = 0 (No,Off,Disabled,Reset,"0")
# Field 5: Arrival Circle Entered = 0 (No,Off,Disabled,Reset,"0")
# Field 6: Calculation Type = 3 (Null)
# Field 7: ETA Time = Not Available
# Field 8: ETA Date = Not Available
# Field 9: Bearing, Origin To Destination Waypoint = Not Available
# Field 10: Bearing, Position To Destination Waypoint = 6.2565 Radians (358.471 Degrees)
# Field 11: Origin Waypoint Number = 1 NGW only transcribes purely numeric WPT numbers?
# Field 12: Destination Waypoint Number = Not Available “swanto” is not numeric, therefore not converted?
# Field 13: Destination Wpt Latitude = 47° 03.565980' N (47.0594330°)
# Field 14: Destination Wpt Longitude = 122° 53.805000' W (-122.8967500°)
# Field 15: Waypoint Closing Velocity = 0.00 Metre Per Second (0.00 Knots)



# "prio":2,"src":7,"dst":255,"pgn":130306,"description":"Wind Data","fields":{"Wind Speed":0.00,"Wind Angle":162.8,"Reference":"Apparent"}}
# 2015-12-19T20:36:40.299Z,2,130306,7,255,8,ff,00,00,fe,6e,fa,ff,ff
# ff ,  00,00,  fe ,6e,  fa,  ff,ff
# 255,  00,00,  28414 ,  2, 255,255

# "prio":2,"src":1,"dst":255,"pgn":130306,"description":"Wind Data","fields":{"Wind Speed":0.08,"Wind Angle":104.9,"Reference":"True (boat referenced)"}}
# 2015-12-19T20:36:40.299Z,2,130306,1,255,8,ff,08,00,7d,47,fb,ff,ff
# ff ,  08,00,  7d,47,  fb,   ff,ff
# 255,  8,      18301,  3

# "prio":2,"src":1,"dst":255,"pgn":130306,"description":"Wind Data","fields":{"Wind Speed":0.05,"Wind Angle":100.3,"Reference":"True (boat referenced)"}}
# 2015-12-19T20:37:08.257Z,2,130306,1,255,8,ff,05,00,68,44,fb,ff,ff
# ff,   05,00,  68,44,fb,ff,ff
# 255,  5


