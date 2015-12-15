require 'socket'
require 'pry'
host = '127.0.0.1'
port = 7000
server = TCPServer.new(host, port)
p "Initilize server #{host}:#{port}"

loop do
  Thread.start(server.accept) do |client|
    while line = client.gets do
      p "#{Time.now} - #{line}"
    end
  end
end

Example
# "2015-12-15 23:17:21 +0100 - $ECRMB,A,0.000,L,001,002,3609.727,N,00522.316,W,0.821,291.359,nan,V*48\r\n"
# "2015-12-15 23:17:21 +0100 - $ECRMC,221721,A,3609.429,N,00521.371,W,nan,nan,151215,1.353,W*65\r\n"
# "2015-12-15 23:17:21 +0100 - $ECAPB,A,A,0.00,L,N,V,V,291.27,T,002,291.36,T,291.36,T*3E\r\n"
# "2015-12-15 23:17:21 +0100 - $ECXTE,A,A,0.000,L,N*4F\r\n"
