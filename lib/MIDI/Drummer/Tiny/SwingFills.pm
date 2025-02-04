package MIDI::Drummer::Tiny::SwingFills;

use Moo;
use strictures 2;
use MIDI::Util qw(dura_size);
use namespace::clean;

=head1 SYNOPSIS

  use MIDI::Drummer::Tiny;
  use MIDI::Drummer::Tiny::SwingFills;

  my $d = MIDI::Drummer::Tiny->new;
  my $f = MIDI::Drummer::Tiny::SwingFills->new;

  for my $i (1 .. $d->beats * $d->bars) {
    my $remainder = $d->beats * $d->bars - $i;
    my $fill = $f->get_fill($d, $d->ride2);
    if ($remainder == $fill->{dura}) {
      $fill->{fill}->();
      last;
    }
    else {
      $d->note($d->quarter, $d->open_hh, $_ % 2 ? $d->kick : $d->snare);
    }
  }

=head1 DESCRIPTION

TBD

=cut

=head1 METHODS

=head2 new

  $f = MIDI::Drummer::Tiny::Fills->new;

Return a new C<MIDI::Drummer::Tiny::Fills> object.

=head2 get_fill

 $fill = $f->get_fill($drummer_obj, $cymbal);

Return a random fill given a B<drummer_object> and an optional
B<cymbal>.

The fill that is returned is a hash reference with keys: C<fill> - a
code reference, and C<dura> - the numerical duration of the fill.

=cut

sub get_fill {
    my ($self, $drummer, $cymbal) = @_;
    my $fills = $self->_fills($drummer, $cymbal);
    my @keys = keys %$fills;
    my $fill = $keys[ int rand @keys ];
    return $fills->{$fill};
}

sub _fills {
    my ($self, $d, $cymbal) = @_;
    $cymbal ||= $d->closed_hh;
    my %fills = (

        1 => {
            fill => sub {
                $d->note($d->dotted_eighth, $d->kick, $cymbal);
                $d->note($d->sixteenth, $d->snare);
                $d->note($d->triplet_eighth, $d->kick, $d->snare);
                $d->note($d->triplet_eighth, $d->snare);
                $d->note($d->triplet_eighth, $d->snare);
            },
            dura => dura_size($d->half),
        },

        2 => {
            fill => sub {
                $d->note($d->dotted_eighth, $d->kick, $cymbal);
                $d->note($d->sixteenth, $d->snare);
                $d->note($d->dotted_eighth, $d->snare);
                $d->note($d->sixteenth, $d->kick, $cymbal);
            },
            dura => dura_size($d->half),
        },

        3 => {
            fill => sub {
                $d->note($d->eighth, $d->kick, $cymbal);
                $d->note($d->triplet_sixteenth, $d->snare);
                $d->note($d->triplet_sixteenth, $d->snare);
                $d->note($d->triplet_sixteenth, $d->snare);
                $d->note($d->dotted_eighth, $d->snare);
                $d->note($d->sixteenth, $d->kick, $cymbal);
            },
            dura => dura_size($d->half),
        },

        4 => {
            fill => sub {
                $d->note($d->dotted_eighth, $d->kick, $cymbal);
                $d->note($d->sixteenth, $d->snare);
                $d->note($d->triplet_eighth, $d->kick, $d->snare);
                $d->note($d->triplet_eighth, $d->snare);
                $d->note($d->triplet_eighth, $d->snare);
                $d->note($d->triplet_eighth, $d->kick, $d->snare);
                $d->note($d->triplet_eighth, $d->snare);
                $d->note($d->triplet_eighth, $d->snare);
                $d->note($d->triplet_eighth, $d->kick, $d->snare);
                $d->note($d->triplet_eighth, $d->snare);
                $d->note($d->triplet_eighth, $d->snare);
            },
            dura => dura_size($d->whole),
        },

        5 => {
            fill => sub {
                $d->note($d->dotted_eighth, $d->kick, $d->snare, $cymbal);
                $d->note($d->sixteenth, $cymbal);
                $d->note($d->eighth, $d->kick, $cymbal);
                $d->note($d->sixteenth, $d->snare);
                $d->note($d->sixteenth, $d->snare);
                $d->note($d->dotted_eighth, $d->snare);
                $d->note($d->sixteenth, $d->kick, $cymbal);
            },
            dura => dura_size($d->dotted_half),
        },

        6 => {
            fill => sub {
                $d->note($d->dotted_eighth, $d->kick, $d->snare, $cymbal);
                $d->note($d->sixteenth, $cymbal);
                $d->note($d->dotted_eighth, $d->kick, $cymbal);
                $d->note($d->sixteenth, $d->snare);
                $d->note($d->dotted_eighth, $d->snare);
                $d->note($d->sixteenth, $d->kick);
            },
            dura => dura_size($d->dotted_half),
        },

        7 => {
            fill => sub {
                $d->note($d->dotted_eighth, $d->snare, $cymbal);
                $d->note($d->sixteenth, $d->snare, $cymbal);
                $d->note($d->quarter, $d->snare, $cymbal);
                $d->note($d->dotted_eighth, $d->kick, $cymbal);
                $d->note($d->sixteenth, $d->kick);
            },
            dura => dura_size($d->dotted_half),
        },

        8 => {
            fill => sub {
                $d->note($d->dotted_eighth, $d->snare, $cymbal);
                $d->note($d->sixteenth, $d->kick, $cymbal);
                $d->note($d->quarter, $d->kick, $cymbal);
                $d->note($d->dotted_eighth, $d->snare, $cymbal);
                $d->note($d->sixteenth, $d->kick, $cymbal);
            },
            dura => dura_size($d->dotted_half),
        },

        9 => {
            fill => sub {
                my $initial = 49;
                my $range = 39;
                my $step = sprintf '%.0f', $range / 9;
                my $n = 0;
                $d->note($d->dotted_eighth, $d->kick, $cymbal);
                $d->note($d->sixteenth, $d->snare);
                $d->note($d->triplet_eighth, $d->kick, $d->snare, 'v' . ($initial + ($n++ * $step)));
                $d->note($d->triplet_eighth, $d->snare,           'v' . ($initial + ($n++ * $step)));
                $d->note($d->triplet_eighth, $d->snare,           'v' . ($initial + ($n++ * $step)));
                $d->note($d->triplet_eighth, $d->kick, $d->snare, 'v' . ($initial + ($n++ * $step)));
                $d->note($d->triplet_eighth, $d->snare,           'v' . ($initial + ($n++ * $step)));
                $d->note($d->triplet_eighth, $d->snare,           'v' . ($initial + ($n++ * $step)));
                $d->note($d->triplet_eighth, $d->kick, $d->snare, 'v' . ($initial + ($n++ * $step)));
                $d->note($d->triplet_eighth, $d->snare,           'v' . ($initial + ($n++ * $step)));
                $d->note($d->triplet_eighth, $d->snare,           'v' . ($initial + ($n++ * $step)));
            },
            dura => dura_size($d->whole),
        },

        10 => {
            fill => sub {
                $d->note($d->dotted_eighth, $d->kick, $cymbal);
                $d->note($d->sixteenth, $d->snare);
                $d->note($d->dotted_eighth, $d->snare, $cymbal);
                $d->note($d->sixteenth, $d->kick, $cymbal);
                $d->note($d->dotted_eighth, $d->snare, $cymbal);
                $d->note($d->sixteenth, $d->snare);
                $d->note($d->dotted_eighth, $d->kick, $cymbal);
                $d->note($d->sixteenth, $cymbal);
            },
            dura => dura_size($d->whole),
        },

        11 => {
            fill => sub {
                $d->note($d->dotted_eighth, $d->kick, $cymbal);
                $d->note($d->sixteenth, $d->snare);
                $d->note($d->dotted_eighth, $d->snare, $cymbal);
                $d->note($d->sixteenth, $d->kick, $cymbal);
                $d->note($d->dotted_eighth, $d->kick, $cymbal);
                $d->note($d->sixteenth, $d->snare);
                $d->note($d->dotted_eighth, $d->snare, $cymbal);
                $d->note($d->sixteenth, $d->kick, $cymbal);
            },
            dura => dura_size($d->whole),
        },

        12 => {
            fill => sub {
                $d->note($d->dotted_eighth, $d->snare, $cymbal);
                $d->note($d->sixteenth, $d->kick);
                $d->note($d->dotted_eighth, $cymbal);
                $d->note($d->sixteenth, $d->snare, $cymbal);
                $d->note($d->quarter, $d->kick, $cymbal);
                $d->note($d->dotted_eighth, $d->kick, $cymbal);
                $d->note($d->sixteenth, $cymbal);
            },
            dura => dura_size($d->whole),
        },

        13 => {
            fill => sub {
                $d->note($d->dotted_eighth, $d->kick, $cymbal);
                $d->note($d->sixteenth, $d->snare);
                $d->note($d->triplet_eighth, $d->snare);
                $d->note($d->triplet_eighth, $d->snare);
                $d->note($d->triplet_eighth, $d->snare);
                $d->note($d->dotted_eighth, $d->snare);
                $d->note($d->sixteenth, $d->kick);
                $d->note($d->quarter, $d->kick);
            },
            dura => dura_size($d->whole),
        },

        14 => {
            fill => sub {
                $d->note($d->dotted_eighth, $d->kick, $cymbal);
                $d->note($d->sixteenth, $d->snare);
                $d->note($d->dotted_eighth, $cymbal);
                $d->note($d->sixteenth, $d->snare, $cymbal);
                $d->note($d->dotted_eighth, $cymbal);
                $d->note($d->sixteenth, $d->kick);
                $d->note($d->dotted_eighth, $cymbal);
                $d->note($d->sixteenth, $d->kick);
            },
            dura => dura_size($d->whole),
        },

        15 => {
            fill => sub {
                $d->note($d->dotted_eighth, $d->kick, $cymbal);
                $d->note($d->sixteenth, $d->snare);
                $d->note($d->dotted_eighth, $d->kick, $cymbal);
                $d->note($d->sixteenth, $d->snare, $cymbal);
                $d->note($d->quarter, $d->kick, $cymbal);
                $d->note($d->dotted_eighth, $d->kick, $cymbal);
                $d->note($d->sixteenth, $d->snare, $cymbal);
            },
            dura => dura_size($d->whole),
        },

        16 => {
            fill => sub {
                $d->note($d->triplet_eighth, $d->kick, $d->snare, $cymbal);
                $d->rest($d->triplet_eighth);
                $d->note($d->triplet_eighth, $cymbal);
                $d->note($d->triplet_eighth, $d->kick, $cymbal);
                $d->rest($d->triplet_eighth);
                $d->note($d->triplet_eighth, $d->snare);
                $d->note($d->triplet_eighth, $d->kick, $cymbal);
                $d->note($d->triplet_eighth, $d->snare);
                $d->note($d->triplet_eighth, $d->snare, $cymbal);
            },
            dura => dura_size($d->dotted_half),
        },

        17 => {
            fill => sub {
                $d->note($d->dotted_eighth, $d->kick, $d->snare, $cymbal);
                $d->note($d->sixteenth, $cymbal);
                $d->note($d->quarter, $d->kick, $cymbal);
                $d->note($d->triplet_sixteenth, $d->snare);
                $d->note($d->triplet_sixteenth, $d->snare);
                $d->note($d->triplet_sixteenth, $d->snare);
                $d->note($d->dotted_eighth, $d->snare);
                $d->note($d->sixteenth, $d->kick);
            },
            dura => dura_size($d->dotted_half),
        },

        18 => {
            fill => sub {
                $d->note($d->triplet_eighth, $d->kick, $cymbal);
                $d->note($d->triplet_eighth, $d->snare);
                $d->rest($d->triplet_eighth);
                $d->note($d->triplet_eighth, $d->snare, $cymbal);
                $d->rest($d->triplet_eighth);
                $d->note($d->triplet_eighth, $d->snare, $cymbal);
                $d->note($d->triplet_eighth, $d->snare, $cymbal);
                $d->note($d->triplet_eighth, $d->kick);
                $d->rest($d->triplet_eighth);
                $d->note($d->triplet_eighth, $d->kick, $cymbal);
                $d->rest($d->triplet_eighth);
                $d->note($d->triplet_eighth, $d->kick, $cymbal);
            },
            dura => dura_size($d->dotted_half),
        },

        19 => {
            fill => sub {
                $d->note($d->dotted_eighth, $d->kick, $cymbal);
                $d->note($d->sixteenth, $d->snare);
                $d->note($d->dotted_eighth, $d->kick, $cymbal);
                $d->note($d->sixteenth, $cymbal);
                $d->note($d->dotted_eighth, $d->kick, $cymbal);
                $d->note($d->sixteenth, $d->snare);
                $d->note($d->dotted_eighth, $d->kick, $cymbal);
                $d->note($d->sixteenth, $d->snare,  $cymbal);
            },
            dura => dura_size($d->whole),
        },

        20 => {
            fill => sub {
                $d->flam($d->triplet_eighth, $d->snare);
                $d->note($d->triplet_eighth, $d->kick);
                $d->note($d->triplet_eighth, $d->kick);
                $d->flam($d->triplet_eighth, $d->snare);
                $d->note($d->triplet_eighth, $d->kick);
                $d->note($d->triplet_eighth, $d->kick);
            },
            dura => dura_size($d->half),
        },

        21 => {
            fill => sub {
                $d->note($d->triplet_eighth, $d->kick);
                $d->flam($d->triplet_eighth, $d->snare);
                $d->note($d->triplet_eighth, $d->kick);
                $d->flam($d->triplet_eighth, $d->snare);
                $d->note($d->triplet_eighth, $d->kick);
                $d->flam($d->triplet_eighth, $d->snare);
                $d->note($d->triplet_eighth, $d->kick);
                $d->flam($d->triplet_eighth, $d->snare);
                $d->note($d->triplet_eighth, $d->kick);
                $d->flam($d->triplet_eighth, $d->snare);
                $d->note($d->triplet_eighth, $d->kick);
                $d->note($d->triplet_eighth, $d->kick);
            },
            dura => dura_size($d->whole),
        },

    );
    return \%fills;
}

1;

__END__

=head1 SEE ALSO

TBD

=cut
