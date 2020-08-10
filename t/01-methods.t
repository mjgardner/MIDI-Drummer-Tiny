#!/usr/bin/env perl
use strict;
use warnings;

use Test::More;

use_ok 'MIDI::Drummer::Tiny';

my $d = new_ok 'MIDI::Drummer::Tiny';

isa_ok $d->score, 'MIDI::Simple';

is $d->beats, 4, 'beats computed';
is $d->divisions, 4, 'divisions computed';

my @score = $d->score->Score;
is $score[1]->[0], 'time_signature', 'time signature added';
is $score[1]->[2], 4, '4 beats';

$d->note($d->quarter, $d->closed_hh);
@score = $d->score->Score;
is $score[3]->[0], 'note', 'note added';

$d->set_time_sig('5/8');
@score = $d->score->Score;
is $score[4]->[0], 'time_signature', 'time signature changed';
is $score[4]->[2], 5, '5 beats';

is $d->beats, 5, 'beats computed';
is $d->divisions, 8, 'divisions computed';

done_testing();
