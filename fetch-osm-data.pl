#!/usr/bin/env perl

use strict;
use warnings;

use feature 'say';

use Text::CSV;
use WWW::Mechanize;
use JSON;
use URI::Escape;


# root url openstreetmap search API
my $osmapi = 'http://nominatim.openstreetmap.org/search/';

# csv file of public wlan in berlin
my $csv_in   = 'cleaned-public-wlan-berlin.csv';
my $json_out = 'public-wlan-berlin.json';
my $csv_out  = 'public-wlan-berlin.csv';

open my $csv_in_fh, "<", $csv_in or die "$csv_in: $!";
open my $csv_out_fh, ">", $csv_out or die "$csv_out: $!";
open my $json_out_fh, ">", $json_out or die "$json_out: $!";

# create CSV object, set seperator to ';'
my $csv = Text::CSV->new( { binary => 1, sep_char => ';' } );

# skip the header row
my $rows = $csv->getline_all($csv_in_fh, 1);

# use some nicer fieldnames to identify data, used as new csv header
my @fields = qw(location street zip city charge carrier area longitude latitude);

my @wlans;

for my $row (@$rows) {
  my %cells;

  # we don't need all available fields, some are redundant anyways.
  @cells{@fields} = @$row[1, 4..9];
  
  $cells{charge} = "kostenfrei" if $cells{charge} eq 'J';
  $cells{charge} = "kostenpflichtig" if $cells{charge} eq 'N';

  # open street map API query - supports many different styles!
  # http://openstreetmapapi/country/zipcode/city/street?otherparams
  my $mech  = WWW::Mechanize->new();
  my $query = $osmapi . 'de/' . 
              $cells{zip} . '/' . 
              $cells{city} . '/' . 
              uri_escape($cells{street}) . 
              '?format=json&addressdetails=1';

  my $response = $mech->get($query);
  my $result;

  if ($response->is_success) {
    $result = from_json( $response->content() );
  }

  $cells{osmquery}  = $query;
  $cells{latitude}  = sprintf("%.3f", $result->[0]->{lat});
  $cells{longitude} = sprintf("%.3f", $result->[0]->{lon});

  push @wlans, \%cells;
  
  # don't kill other people's webservices
  sleep 5;
}


# write out new, cleaner csv data, ordered by @fields
$csv = Text::CSV->new( { binary => 1, sep_char => ';', always_quote => 1, eol => $/} );

$csv->print($csv_out_fh, \@fields);

foreach ( @wlans ) {
  $csv->print($csv_out_fh, [ @$_{@fields} ]) 
      or die "Couldn't print CSV output to $csv_out: $!";
}

# write out new json file, pretty-fied output
my $json = to_json(\@wlans, { pretty => 1 });

print $json_out_fh $json or die "Couldn't print JSON output to $json_out: $!";

