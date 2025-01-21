use strict;
use warnings;
use utf8;
use open qw(:std :encoding(utf8));

use Test::More tests => 2;

use JSON::JQ;

my $jq = JSON::JQ->new({ script => '.', unicode => 1 });

utf8::downgrade(my $latin1_down = "døwn");
utf8::upgrade(my $latin1_up = "üp");
my $emoji = "\N{SNOWMAN}";

my $data = {
    map +(
         $_ => {
             scalar => $_,
             array => [ $_ ],
         }
     ), $latin1_down, $latin1_up, $emoji
};

is_deeply($jq->process({ data => $data }), $data,
          'unicode data roundtrip');

my $jq2 = JSON::JQ->new({ script => '.[] | .[1:2]', unicode => 1});

my $data2 = [ $latin1_up, $latin1_down, "u$emoji" ];
is_deeply([$jq2->process({ data => $data2 })],
          [ map substr($_, 1, 1), @$data2 ],
          'unicode character offsets');
