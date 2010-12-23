#!/usr/bin/perl -w

use Test::More;

use t::app::Main;
use strict;

use DateTime;

system "sqlite3 t/app/db/example.db < t/app/db/example.sql";
if ($@)
{
  plan skip_all => "sqlite3 is require for these tests : $@";
  exit;
}
eval "use DBIx::Class::IntrospectableM2M";
if ($@)
{
  plan skip_all => "This test is about compatibility with component IntrospectableM2M but you don't install it";
  exit;
}

plan tests => 3;

system "perl t/app/insertdb.pl";

my $schema = t::app::Main->connect('dbi:SQLite:t/app/db/example.db');

my @rs = $schema->resultset('M2MCd')->search({'title' => 'Thriller'});
my $cd = $rs[0];
my $rh_result = {'artistid' => $cd->artistid(),'cdid' => $cd->cdid(),'title' => $cd->title, 'date' => undef, 'last_listen' => undef};
is_deeply( $cd->columns_data, $rh_result, "columns_data return all column value of object");

use Data::Dumper 'Dumper';

my @artists = $cd->m2martists_columns_data;
my $artist = $artists[0];
my $art = $schema->resultset('M2MArtist')->find($artist->{artistid});

is(scalar(@artists),2, "2 artists for 1 cd");
is_deeply( $art->columns_data, $artist, "_columns_data work for many to many association with IntrospectableM2M");
