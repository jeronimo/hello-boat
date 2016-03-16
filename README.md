## Hello Boat

This is `ruby` code which uses TCP sockets to parse NMEA0183 `RMB`/`XTE` sentences sent by OpenCPN and covert them to NMEA2000 and send to autopilot via Actisense USB
It was tested only with Simrad AP26 and OpenCPN 4.0+

## Warning
It is still a spike which is slowly becoming more publicly used

## Canboat
The code relies on [Canboat](https://github.com/canboat/canboat):

* It reads pgns.json file which is currently not valid json (https://github.com/canboat/canboat/issues/56)
* It expects that n2kd_monitor is already running and tries to connect to it as a client

## Config
* Modify `config.yml` to define host and ports and where pgns.json is placed
* Modify `conversion.yml` if you need more sentences to be converted (syntax and logic explanation TBA)

## Execute
`./bin/hello-boat` or `./bin/hello-boat >> hello-boat.log &` to run it in background

## License
This is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

It is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with it.  If not, see <http://www.gnu.org/licenses/>.


