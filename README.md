# AirQuality

Recruitment exercise Elixir project, it will fetch and store carbon
intensity records from this API:
https://carbon-intensity.github.io/api-definitions/#carbon-intensity-api-v2-0-0

Modules:


## AirQuality.Client
consumes the carbon, fetching emission intensities API for the latest
measurement and all measurements for a given date. The API
measurements have a time precision of half an hour and seems to have a
4 hrs delay.
It's tested using a `cowboy`/`plug` mock server.


## AirQuality.Store
has the responsability to store and retrieve
records from an Mnesia database table. It also retrieves a `Stream` of
numeric timestamps for missing records.


## AirQuality.Poller
is a `GenServer`, when spawned it fetches and store all missing
records since january 2018, later it will fetch and store the current
or missing measurements every half an hour. 
The genserver is supervised by **AirQuality** application. 
Failure to fetch will crash Poller, triggering a Poller restart and a
subsequent attempt to fetch missing records.