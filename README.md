## Hello Boat

This is `ruby` code which uses TCP sockets to parse NMEA0183 sentences (currently only `RMB`/`XTE`) sent by OpenCPN and coverts them to NMEA2000 and sends to autopilot via Actisense NGT-1-USB
It was tested only with Simrad AP26 and OpenCPN 4.0+

## Warning
It is still a spike with only minor tests coverage and still needs some work to become publicly used software

## Requirements
The code relies on [Canboat](https://github.com/canboat/canboat):

* It expects that n2kd_monitor is already running and tries to connect to it as a client

## Config
* `cp config.yml.default config.yml` and modify it to define host and ports and where pgns.json is placed
* Modify `conversion.yml` if you need more sentences to be converted (syntax and logic explanation TBA)

## Execute
`./bin/hello-boat` or `./bin/hello-boat >> hello-boat.log &` to run it in background

## Testing
Tests can be run by `rake` task. Though one test is still failing and more tests need to be written including code refactoring

## License
This is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

It is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with it.  If not, see <http://www.gnu.org/licenses/>.


