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
    @encoder.encode({pgn: 130306, "fields":{"windSpeed" => 0.08,"windAngle" => 104.9,"reference" => "True (boat referenced)"}})
    # original 'ff,08,00,7d,47,fb,ff,ff'
    assert_equal 'ff,08,00,85,47,0b,ff,ff', @encoder.frame
  end

  def test_encoding_navigation_data
    # "bearingPositionToDestinationWaypoint"=>"291.359" - not sure if this one is correct
    @encoder.encode({pgn: 129284, "fields":{"distanceToWaypoint"=>"0.821", "originWaypointNumber"=>"002", "destinationWaypointNumber"=>"001", "destinationLatitude"=>"36.16211666666667", "destinationLongitude"=>"00522.316", "waypointClosingVelocity"=>"nan"}})
    assert_equal 'ff,52,00,00,00,00,ff,ff,ff,ff,ff,ff,ff,ff,ff,ff,02,00,00,00,01,00,00,00,af,e6,8d,15,8c,31,75,13,ff,ff', @encoder.frame
  end

  def test_encoding_navigation_data_by_example
    # "bearingPositionToDestinationWaypoint"=>"358.471" - not sure if this one is correct
    # Found example - 10,a6,ba,00,00,00,ff,ff,ff,ff,ff,ff,ff,ff,65,f4,01,00,00,00,ff,ff,ff,ff,1a,b3,0c,1c,b4,71,bf,b6,00,00'
    @encoder.encode({pgn: 129284, "fields":{"sid" => 16,"distanceToWaypoint"=>"477.82", "courseBearingReference" => "True", "bearingPositionToDestinationWaypoint"=>"358.471", "originWaypointNumber"=>"001", "destinationWaypointNumber"=>"swanto", "destinationLatitude"=>"47.0594330", "destinationLongitude"=>"-122.8967500", "waypointClosingVelocity"=>"0"}})
    assert_equal '10,a6,ba,00,00,00,ff,ff,ff,ff,ff,ff,ff,ff,65,f4,01,00,00,00,ff,ff,ff,ff,1a,b3,0c,1c,00,8f,40,49,00,00', @encoder.frame

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


