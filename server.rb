require 'socket'
require 'pry'

require './helpers'
require './client'

host = '127.0.0.1'
port = 7000
p "Initilize server #{host}:#{port}"

class Server
  def initialize(host, port)
    Coversions.init
    @server = TCPServer.open(host, port)
    @encoder = Encoder.new
  end

  def run
    loop do
      Thread.start(@server.accept) do |client|
        begin
          @client = Client.new
          while line = client.gets do

            puts "-->> #{Time.now} - #{line}"
            parsed = Parser.convert(line)

            unless parsed['fields'].empty?
              @encoder.encode(parsed)
              @client.send(@encoder.full_sentence)
              puts "<<--#{@encoder.full_sentence}"
            end
          end
        rescue Exception => e
          puts e.message
          puts e.backtrace.inspect
        end
      end
    end
  end


end

s = Server.new(host, port)
s.run


# Examples

# "2015-12-15 23:17:21 +0100 - $ECRMB,A,0.000,L,001,002,3609.727,N,00522.316,W,0.821,291.359,nan,V*48\r\n"
# "2015-12-15 23:17:21 +0100 - $ECRMC,221721,A,3609.429,N,00521.371,W,nan,nan,151215,1.353,W*65\r\n"
# "2015-12-15 23:17:21 +0100 - $ECAPB,A,A,0.00,L,N,V,V,291.27,T,002,291.36,T,291.36,T*3E\r\n"
# "2015-12-15 23:17:21 +0100 - $ECXTE,A,A,0.000,L,N*4F\r\n"

# "2015-12-19 21:53:53 +0100 - $ECRMB,A,0.000,L,,001,3609.706,N,00522.408,W,0.885,288.301,nan,V*7A\r\n"
# "2015-12-19 21:53:53 +0100 - $ECRMC,205353,A,3609.428,N,00521.370,W,nan,nan,191215,1.351,W*6C\r\n"
# "2015-12-19 21:53:53 +0100 - $ECAPB,A,A,0.00,L,N,V,V,288.24,T,001,288.30,T,288.30,T*36\r\n"
# "2015-12-19 21:53:53 +0100 - $ECXTE,A,A,0.000,L,N*4F\r\n"
# "2015-12-19 21:53:54 +0100 - $ECRMB,A,0.000,L,,001,3609.706,N,00522.408,W,0.885,288.301,nan,V*7A\r\n"
# "2015-12-19 21:53:54 +0100 - $ECRMC,205354,A,3609.428,N,00521.370,W,nan,nan,191215,1.351,W*6B\r\n"
# "2015-12-19 21:53:54 +0100 - $ECAPB,A,A,0.00,L,N,V,V,288.24,T,001,288.30,T,288.30,T*36\r\n"
# "2015-12-19 21:53:54 +0100 - $ECXTE,A,A,0.000,L,N*4F\r\n"
# "2015-12-19 21:53:55 +0100 - $ECRMB,A,0.000,L,,001,3609.706,N,00522.408,W,0.885,288.301,nan,V*7A\r\n"
# "2015-12-19 21:53:55 +0100 - $ECRMC,205355,A,3609.428,N,00521.370,W,nan,nan,191215,1.351,W*6A\r\n"
# "2015-12-19 21:53:55 +0100 - $ECAPB,A,A,0.00,L,N,V,V,288.24,T,001,288.30,T,288.30,T*36\r\n"
# "2015-12-19 21:53:55 +0100 - $ECXTE,A,A,0.000,L,N*4F\r\n"
# "2015-12-19 21:53:56 +0100 - $ECRMB,A,0.000,L,,001,3609.706,N,00522.408,W,0.885,288.301,nan,V*7A\r\n"
# "2015-12-19 21:53:56 +0100 - $ECRMC,205356,A,3609.428,N,00521.370,W,nan,nan,191215,1.351,W*69\r\n"
# "2015-12-19 21:53:56 +0100 - $ECAPB,A,A,0.00,L,N,V,V,288.24,T,001,288.30,T,288.30,T*36\r\n"
# "2015-12-19 21:53:56 +0100 - $ECXTE,A,A,0.000,L,N*4F\r\n"
# "2015-12-19 21:53:57 +0100 - $ECRMB,A,0.000,L,,001,3609.706,N,00522.408,W,0.885,288.301,nan,V*7A\r\n"
# "2015-12-19 21:53:57 +0100 - $ECRMC,205357,A,3609.428,N,00521.370,W,nan,0.000,191215,1.351,W*27\r\n"
# "2015-12-19 21:53:57 +0100 - $ECAPB,A,A,0.00,L,N,V,V,288.24,T,001,288.30,T,288.30,T*36\r\n"
# "2015-12-19 21:53:57 +0100 - $ECXTE,A,A,0.000,L,N*4F\r\n"
# "2015-12-19 21:53:58 +0100 - $ECRMB,A,0.000,L,,001,3609.706,N,00522.408,W,0.885,288.301,nan,V*7A\r\n"
# "2015-12-19 21:53:58 +0100 - $ECRMC,205358,A,3609.428,N,00521.370,W,nan,nan,191215,1.351,W*67\r\n"
# "2015-12-19 21:53:58 +0100 - $ECAPB,A,A,0.00,L,N,V,V,288.24,T,001,288.30,T,288.30,T*36\r\n"
# "2015-12-19 21:53:58 +0100 - $ECXTE,A,A,0.000,L,N*4F\r\n"
# "2015-12-19 21:53:59 +0100 - $ECRMB,A,0.000,L,,001,3609.706,N,00522.408,W,0.885,288.301,nan,V*7A\r\n"
# "2015-12-19 21:53:59 +0100 - $ECRMC,205359,A,3609.428,N,00521.370,W,nan,nan,191215,1.351,W*66\r\n"
# "2015-12-19 21:53:59 +0100 - $ECAPB,A,A,0.00,L,N,V,V,288.24,T,001,288.30,T,288.30,T*36\r\n"
# "2015-12-19 21:53:59 +0100 - $ECXTE,A,A,0.000,L,N*4F\r\n"
# "2015-12-19 21:54:00 +0100 - $ECRMB,A,0.000,L,,001,3609.706,N,00522.408,W,0.885,288.301,nan,V*7A\r\n"
# "2015-12-19 21:54:00 +0100 - $ECRMC,205400,A,3609.428,N,00521.370,W,nan,nan,191215,1.351,W*6D\r\n"
# "2015-12-19 21:54:00 +0100 - $ECAPB,A,A,0.00,L,N,V,V,288.24,T,001,288.30,T,288.30,T*36\r\n"
# "2015-12-19 21:54:00 +0100 - $ECXTE,A,A,0.000,L,N*4F\r\n"


# $ECRMB,A,0.000,L,,001,3609.706,N,00522.408,W,0.885,288.301,nan,V*7A\r\n

# RMB - Recommended Minimum Navigation Information
# PGN -  129283, 129284
# To be sent by a navigation receiver when a destination waypoint is active.
#                                                              14
#         1 2   3 4    5    6       7 8        9 10  11  12  13|  15
#         | |   | |    |    |       | |        | |   |   |   | |   |
#  $--RMB,A,x.x,a,c--c,c--c,llll.ll,a,yyyyy.yy,a,x.x,x.x,x.x,A,m,*hh<CR><LF>

# Field Number:
# 1. Status, A= Active, V = Void
# 2. Cross Track error - nautical miles
# 3. Direction to Steer, Left or Right
# 4. TO Waypoint ID
# 5. FROM Waypoint ID
# 6. Destination Waypoint Latitude
# 7. N or S
# 8. Destination Waypoint Longitude
# 9. E or W
# 10. Range to destination in nautical miles
# 11. Bearing to destination in degrees True
# 12. Destination closing velocity in knots
# 13. Arrival Status, A = Arrival Circle Entered
# 14. FAA mode indicator (NMEA 2.3 and later)
# 15. Checksum

# Example: $GPRMB,A,0.66,L,003,004,4917.24,N,12309.57,W,001.3,052.5,000.5,V*0B



# XTE - Cross-Track Error, Measured
# PGN - 129283 for XTE
#         1 2 3   4 5 6   7
#         | | |   | | |   |
#  $--XTE,A,A,x.x,a,N,m,*hh<CR><LF>

# Field Number:
# 1. Status
#   V = Loran-C Blink or SNR warning
#   V = general warning flag or other navigation systems when a reliable fix is not available
# 2. Status
#   V = Loran-C Cycle Lock warning flag
#   A = OK or not used
# 3. Cross Track Error Magnitude
# 4. Direction to steer, L or R
# 5. Cross Track Units, N = Nautical Miles
# 6. FAA mode indicator (NMEA 2.3 and later, optional)
# 7. Checksum
