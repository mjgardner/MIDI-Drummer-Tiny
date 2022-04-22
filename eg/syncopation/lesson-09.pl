#!/usr/bin/env perl
use strict;
use warnings;

use MIDI::Drummer::Tiny;

my $bpm = shift || 100;

my $d = MIDI::Drummer::Tiny->new(
    bpm    => $bpm,
    file   => "$0.mid",
    kick   => 'n36',
    snare  => 'n40',
    reverb => 15,
);

$d->sync(
    \&snare,
    \&kick,
    \&hhat,
);

$d->write;

sub snare {
    $d->combinatorial( $d->snare, {
        vary => {
            0 => sub {
                $d->note( $d->sixteenth, $d->snare );
                $d->note( $d->sixteenth, $d->snare );
                $d->note( $d->sixteenth, $d->snare );
                $d->note( $d->sixteenth, $d->snare );
            },
            1 => sub {
                $d->note( $d->quarter, $d->snare );
            },
        },
    });
}

sub kick {
    $d->steady( $d->kick );
}

sub hhat {
    $d->steady( $d->closed_hh );
}
