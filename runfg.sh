#! /bin/csh 

fg_ac_path="$(pwd)/ExternalModules/FlightGearAircraft/"

cd /usr/share/flightgear

#setenv LD_LIBRARY_PATH /usr/share/flightgear/lib:$LD_LIBRARY_PATH
#setenv FG_ROOT /usr/share/flightgear/data
#setenv FG_SCENERY /usr/share/flightgear/Scenery:$FG_ROOT/Scenery:$FG_ROOT/WorldScenery

fgfs --fg-aircraft="$fg_ac_path" --aircraft=f16-block-52 --fdm=network,localhost,5501,5502,5503 --fog-fastest --disable-clouds --start-date-lat=2004:06:01:09:00:00 --disable-sound --in-air --enable-freeze --airport=ETAD --runway=23 --altitude=300 --heading=224 --offset-distance=4.72 --offset-azimuth=0 --enable-terrasync --prop:/sim/rendering/shaders/quality-level=0 --enable-hud
