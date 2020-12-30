set relpath=\ExternalModules\FlightGearAircraft\
set curdir=%cd% and %relpath%

C:
cd C:\Program Files\FlightGear

SET FG_ROOT=C:\Program Files\FlightGear\data
.\\bin\fgfs --fg-aircraft=%curdir% --aircraft=f16-block-52 --fdm=network,localhost,5501,5502,5503 --fog-fastest --disable-clouds --start-date-lat=2004:06:01:09:00:00 --disable-sound --in-air --enable-freeze --airport=ETAD --runway=23 --altitude=300 --heading=224 --offset-distance=4.72 --offset-azimuth=0 --enable-terrasync --prop:/sim/rendering/shaders/quality-level=0 --enable-hud
