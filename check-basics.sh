#!/bin/sh -

echo "Checking for some basic modules and libs...";

# check the availability of Leaflets' CDN..
if ! wget -q --spider http://cdn.leafletjs.com/leaflet-0.5/leaflet.js; then 
  echo "CDN of Leaflet.js is unreachable, you probably cannnot use it just now.";
else 
  echo "You can open public-wlan-berlin.html in your brower.";
fi

# check the availability of Open Street Map's API
if ! wget -q --spider http://nominatim.openstreetmap.org/search/; then 
  echo "Open Street Maps API isunreachable, you probably cannnot use it just now.";
else 
  echo "Open Street Map API is available. You can run fetch-osm-data scripts.";
fi

if python -m py_compile fetch-osm-data.py; then
  echo "The script fetch-osm-data.py looks good!";
  rm -f *.pyc
else 
  echo "The script fetch-osm-data.py failed syntax check!";
fi

if perl -c fetch-osm-data.pl; then
  echo "The script fetch-osm-data.pl looks good!";
else
  echo "The script fetch-osm-data.pl failed syntax check!";
fi

echo "Checking for some R libs...";

# R library ggmap
if ! echo 'library("ggmap")' | R --slave >/dev/null 2>&1; then 
  echo "You are missing the R module ggmap."; 
fi

# R library mapproj
if ! echo 'library("mapproj")' | R --slave >/dev/null 2>&1; then 
  echo "You are missing the R module mapproj."; 
fi

echo "Testing R plots...";

# run R visualizations...
for script in *.R; do
  R --slave < $script >/dev/null
  rm -f *.pdf
  rm -f *.png
done;

echo "We're done!"
