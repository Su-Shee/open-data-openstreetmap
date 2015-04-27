#!/usr/bin/env python

import sys
import csv
import json
import requests
import urllib
import time

# open street map base url
osmapi = 'http://nominatim.openstreetmap.org/search/'

# ugly csv file in, clean csv and json out
csv_in   = 'cleaned-public-wlan-berlin.csv'
json_out = 'public-wlan-berlin.json'
csv_out  = 'public-wlan-berlin.csv'

# use some nicer fieldnames to identify data, used as new csv header
fields = ['location', 'street', 'zip', 'city', 'charge', 'carrier', 'area', 'longitude', 'latitude']
wlans   = []

csv.register_dialect('semicolon', delimiter = ';')

with open(csv_in, 'r') as fh:
    reader = csv.reader(fh, dialect='semicolon')
    
    for row in reader:
      try:
        # we don't need all available fields, some are redundant anyways.
        cells = dict(zip(fields, row[1:2] + row[4:9]))
        cells['charge'] = 'kostenfrei' if cells['charge'] == 'J' else 'kostenpflichtig'

        # open street map API query - supports many different styles!
        # http://openstreetmapapi/country/zipcode/city/street?otherparams
        query = osmapi + 'de/' + cells['zip'] + '/' + cells['city'] + '/' + urllib.quote(cells['street']) + '?format=json&addressdetails=1'

        res = requests.get(query)
        jsondata = res.json()
        
        if not jsondata:
          continue

        cells['osmquery']  = query
        cells['longitude'] = "%.3f" % float(jsondata[0]['lon'])
        cells['latitude']  = "%.3f" % float(jsondata[0]['lat'])

        wlans.append(cells)

      except ValueError:
        continue

      # don't kill other people's webservices
      time.sleep(5)
      

# write out new, cleaner csv data, ordered by @fields
with open(csv_out, 'w') as fh:
  writer = csv.writer(fh, delimiter = ';', quotechar = '"', quoting = csv.QUOTE_ALL)
  writer.writerow(fields)
  for row in wlans:
    writer.writerow(row.values())

# write out new json file, pretty-fied output
with open(json_out, 'w') as fh:
  fh.write(json.dumps(wlans))

