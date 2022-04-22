package MIDI::Drummer::Tiny;

# ABSTRACT: Glorified metronome

our $VERSION = '0.2002';

use Music::Duration;

use Moo;
use strictures 2;
use namespace::clean;

use constant TICKS => 96; # Per quarter note

=head1 SYNOPSIS

 use MIDI::Drummer::Tiny;

 my $d = MIDI::Drummer::Tiny->new(
    file      => 'drums.mid',
    bpm       => 100,
    volume    => 100,
    signature => '5/4',
    bars      => 8,
    reverb    => 0,
    kit       => 25, # TR-808 if using GM Level 2
    #kick  => 'n36', # Override default patch
    #snare => 'n40', # "
 );

 $d->count_in(1);  # Closed hi-hat for 1 bar

 $d->metronome54;  # 5/4 time for the number of bars

 $d->set_time_sig('4/4');

 $d->rest($d->whole);

 $d->metronome44;  # 4/4 time for the number of bars

 $d->flam($d->quarter, $d->snare);
 $d->crescendo_roll([50, 127, 1], $d->eighth, $d->thirtysecond);
 $d->note($d->sixteenth, $d->crash1);
 $d->accent_note(127, $d->sixteenth, $d->crash2);

 # Alternate kick and snare
 $d->note($d->quarter, $d->open_hh, $_ % 2 ? $d->kick : $d->snare)
    for 1 .. $d->beats * $d->bars;

 $d->write;

=head1 DESCRIPTION

This module provides handy defaults and tools to produce a MIDI score
with drum parts.

=for Pod::Coverage BUILD

=cut

sub BUILD {
    my ( $self, $args ) = @_;

    $self->score->noop( 'c' . $self->channel, 'V' . $self->volume );

    if ($self->kit) {
      $self->score->control_change($self->channel, 0, 120);
      $self->score->patch_change($self->channel, $self->kit)
    }

    $self->score->set_tempo( int( 60_000_000 / $self->bpm ) );

    $self->score->control_change($self->channel, 91, $self->reverb);

    $self->set_time_sig;
}

=head1 ATTRIBUTES

=head2 file

Default: C<MIDI-Drummer.mid>

=head2 score

Default: C<MIDI::Simple-E<gt>new_score>

=head2 kit

Default: C<1> (Standard)

If you are going to play the MIDI file with a "General MIDI Level 2"
soundfont, you can change kits.

   8: Room
  16: Power
  24: Electronic
  25: TR-808
  26: ?
  32: Jazz
  40: Brush
  48: Orchestra

=head2 reverb

Default: C<63>

=head2 channel

Default: C<9>

=head2 volume

Default: C<100>

=head2 bpm

Default: C<120>

=head2 bars

Default: C<4>

=head2 signature

Default: C<4/4>

B<beats> / B<divisions>

=head2 beats

Computed given the B<signature>.

=head2 divisions

Computed given the B<signature>.

=head2 counter

  $d->counter( $d->counter + $duration );
  $count = $d->counter;

Beat counter of durations, where a quarter-note is equal to 1. An
eighth-note is 0.5, etc.

=cut

has kit       => ( is => 'ro', default => sub { 0 } );
has reverb    => ( is => 'ro', default => sub { 63 } );
has channel   => ( is => 'ro', default => sub { 9 } );
has volume    => ( is => 'ro', default => sub { 100 } );
has bpm       => ( is => 'ro', default => sub { 120 } );
has file      => ( is => 'ro', default => sub { 'MIDI-Drummer.mid' } );
has bars      => ( is => 'ro', default => sub { 4 } );
has score     => ( is => 'ro', default => sub { MIDI::Simple->new_score } );
has signature => ( is => 'rw', default => sub { '4/4' });
has beats     => ( is => 'rw' );
has divisions => ( is => 'rw' );
has counter   => ( is => 'rw', default => sub { 0 });

=head1 KIT

=over 4

=item click, bell (metronome)

=item open_hh, closed_hh, pedal_hh

=item crash1, crash2, splash, china

=item ride1, ride2, ride_bell

=item snare, acoustic_snare, electric_snare, side_stick, clap

Where the B<snare> is by default the same as the B<acoustic_snare> but
can be overridden with the B<electric_snare> (C<'n40'>).

=item hi_tom, hi_mid_tom, low_mid_tom, low_tom, hi_floor_tom, low_floor_tom

=item kick, acoustic_bass, electric_bass

Where the B<kick> is by default the same as the B<acoustic_bass> but
can be overridden with the B<electric_bass> (C<'n36'>).

=item tambourine, cowbell, vibraslap

=item hi_bongo, low_bongo, mute_hi_conga, open_hi_conga, low_conga, high_timbale, low_timbale

=item high_agogo, low_agogo, cabasa, maracas, short_whistle, long_whistle, short_guiro, long_guiro, claves, hi_wood_block, low_wood_block, mute_cuica, open_cuica

=item mute_triangle, open_triangle

=back

=cut

has click          => ( is => 'ro', default => sub { 'n33' } );
has bell           => ( is => 'ro', default => sub { 'n34' } );
has kick           => ( is => 'ro', default => sub { 'n35' } ); # Alt: 36
has acoustic_bass  => ( is => 'ro', default => sub { 'n35' } );
has electric_bass  => ( is => 'ro', default => sub { 'n36' } );
has side_stick     => ( is => 'ro', default => sub { 'n37' } );
has snare          => ( is => 'ro', default => sub { 'n38' } ); # Alt: 40
has acoustic_snare => ( is => 'ro', default => sub { 'n38' } );
has electric_snare => ( is => 'ro', default => sub { 'n40' } );
has clap           => ( is => 'ro', default => sub { 'n39' } );
has open_hh        => ( is => 'ro', default => sub { 'n46' } );
has closed_hh      => ( is => 'ro', default => sub { 'n42' } );
has pedal_hh       => ( is => 'ro', default => sub { 'n44' } );
has crash1         => ( is => 'ro', default => sub { 'n49' } );
has crash2         => ( is => 'ro', default => sub { 'n57' } );
has splash         => ( is => 'ro', default => sub { 'n55' } );
has china          => ( is => 'ro', default => sub { 'n52' } );
has ride1          => ( is => 'ro', default => sub { 'n51' } );
has ride2          => ( is => 'ro', default => sub { 'n59' } );
has ride_bell      => ( is => 'ro', default => sub { 'n53' } );
has hi_tom         => ( is => 'ro', default => sub { 'n50' } );
has hi_mid_tom     => ( is => 'ro', default => sub { 'n48' } );
has low_mid_tom    => ( is => 'ro', default => sub { 'n47' } );
has low_tom        => ( is => 'ro', default => sub { 'n45' } );
has hi_floor_tom   => ( is => 'ro', default => sub { 'n43' } );
has low_floor_tom  => ( is => 'ro', default => sub { 'n41' } );
has tambourine     => ( is => 'ro', default => sub { 'n54' } );
has cowbell        => ( is => 'ro', default => sub { 'n56' } );
has vibraslap      => ( is => 'ro', default => sub { 'n58' } );
has hi_bongo       => ( is => 'ro', default => sub { 'n60' } );
has low_bongo      => ( is => 'ro', default => sub { 'n61' } );
has mute_hi_conga  => ( is => 'ro', default => sub { 'n62' } );
has open_hi_conga  => ( is => 'ro', default => sub { 'n63' } );
has low_conga      => ( is => 'ro', default => sub { 'n64' } );
has high_timbale   => ( is => 'ro', default => sub { 'n65' } );
has low_timbale    => ( is => 'ro', default => sub { 'n66' } );
has high_agogo     => ( is => 'ro', default => sub { 'n67' } );
has low_agogo      => ( is => 'ro', default => sub { 'n68' } );
has cabasa         => ( is => 'ro', default => sub { 'n69' } );
has maracas        => ( is => 'ro', default => sub { 'n70' } );
has short_whistle  => ( is => 'ro', default => sub { 'n71' } );
has long_whistle   => ( is => 'ro', default => sub { 'n72' } );
has short_guiro    => ( is => 'ro', default => sub { 'n73' } );
has long_guiro     => ( is => 'ro', default => sub { 'n74' } );
has claves         => ( is => 'ro', default => sub { 'n75' } );
has hi_wood_block  => ( is => 'ro', default => sub { 'n76' } );
has low_wood_block => ( is => 'ro', default => sub { 'n77' } );
has mute_cuica     => ( is => 'ro', default => sub { 'n78' } );
has open_cuica     => ( is => 'ro', default => sub { 'n79' } );
has mute_triangle  => ( is => 'ro', default => sub { 'n80' } );
has open_triangle  => ( is => 'ro', default => sub { 'n81' } );

=head1 DURATIONS

=over 4

=item whole, triplet_whole, dotted_whole, double_dotted_whole

=item half, triplet_half, dotted_half, double_dotted_half

=item quarter, triplet_quarter, dotted_quarter, double_dotted_quarter

=item eighth, triplet_eighth, dotted_eighth, double_dotted_eighth

=item sixteenth, triplet_sixteenth, dotted_sixteenth, double_dotted_sixteenth

=item thirtysecond, triplet_thirtysecond, dotted_thirtysecond, double_dotted_thirtysecond

=item sixtyfourth, triplet_sixtyfourth, dotted_sixtyfourth, double_dotted_sixtyfourth

=item onetwentyeighth, triplet_onetwentyeighth, dotted_onetwentyeighth, double_dotted_onetwentyeighth

=back

=cut

has whole                         => (is => 'ro', default => sub { 'wn' });
has triplet_whole                 => (is => 'ro', default => sub { 'twn' });
has dotted_whole                  => (is => 'ro', default => sub { 'dwn' });
has double_dotted_whole           => (is => 'ro', default => sub { 'ddwn' });
has half                          => (is => 'ro', default => sub { 'hn' });
has triplet_half                  => (is => 'ro', default => sub { 'thn' });
has dotted_half                   => (is => 'ro', default => sub { 'dhn' });
has double_dotted_half            => (is => 'ro', default => sub { 'ddhn' });
has quarter                       => (is => 'ro', default => sub { 'qn' });
has triplet_quarter               => (is => 'ro', default => sub { 'tqn' });
has dotted_quarter                => (is => 'ro', default => sub { 'dqn' });
has double_dotted_quarter         => (is => 'ro', default => sub { 'ddqn' });
has eighth                        => (is => 'ro', default => sub { 'en' });
has triplet_eighth                => (is => 'ro', default => sub { 'ten' });
has dotted_eighth                 => (is => 'ro', default => sub { 'den' });
has double_dotted_eighth          => (is => 'ro', default => sub { 'dden' });
has sixteenth                     => (is => 'ro', default => sub { 'sn' });
has triplet_sixteenth             => (is => 'ro', default => sub { 'tsn' });
has dotted_sixteenth              => (is => 'ro', default => sub { 'dsn' });
has double_dotted_sixteenth       => (is => 'ro', default => sub { 'ddsn' });
has thirtysecond                  => (is => 'ro', default => sub { 'xn' });
has triplet_thirtysecond          => (is => 'ro', default => sub { 'txn' });
has dotted_thirtysecond           => (is => 'ro', default => sub { 'dxn' });
has double_dotted_thirtysecond    => (is => 'ro', default => sub { 'ddxn' });
has sixtyfourth                   => (is => 'ro', default => sub { 'yn' });
has triplet_sixtyfourth           => (is => 'ro', default => sub { 'tyn' });
has dotted_sixtyfourth            => (is => 'ro', default => sub { 'dyn' });
has double_dotted_sixtyfourth     => (is => 'ro', default => sub { 'ddyn' });
has onetwentyeighth               => (is => 'ro', default => sub { 'zn' });
has triplet_onetwentyeighth       => (is => 'ro', default => sub { 'tzn' });
has dotted_onetwentyeighth        => (is => 'ro', default => sub { 'dzn' });
has double_dotted_onetwentyeighth => (is => 'ro', default => sub { 'ddzn' });

=head1 METHODS

=head2 new

  $d = MIDI::Drummer::Tiny->new(%arguments);

Return a new C<MIDI::Drummer::Tiny> object.

=head2 note

 $d->note( $d->quarter, $d->closed_hh, $d->kick );
 $d->note( 'qn', 'n42', 'n35' ); # Same thing

Add a note to the score.

This method takes the same arguments as L<MIDI::Simple/"Parameters for n/r/noop">.

=cut

sub note { return shift->score->n(@_) }

=head2 accent_note

  $d->accent_note($accent_value, $d->sixteenth, $d->snare);

Play an accented note.

For instance, this can be a "ghosted note", where the B<accent> is a
smaller number (< 50).  Or a note that is greater than the normal
score volume.

=cut

sub accent_note {
    my $self = shift;
    my $accent = shift;
    my $resume = $self->score->Volume;
    $self->score->Volume($accent);
    $self->note(@_);
    $self->score->Volume($resume);
}

=head2 rest

 $d->rest( $d->quarter );

Add a rest to the score.

This method takes the same arguments as L<MIDI::Simple/"Parameters for n/r/noop">.

=cut

sub rest { return shift->score->r(@_) }

=head2 count_in

 $d->count_in;
 $d->count_in($bars);

Play the closed hihat for the number of beats times the given bars.
If no bars are given, the default times the number of beats is used.

=cut

sub count_in {
    my $self = shift;
    my $bars = shift || $self->bars;
    for my $i ( 1 .. $self->beats * $bars ) {
        $self->note( $self->quarter, $self->closed_hh );
    }
}

=head2 metronome38

  $d->metronome38;
  $d->metronome38($bars);

Add a steady 3/8 beat to the score.

=cut

sub metronome38 {
    my $self = shift;
    my $bars = shift || $self->bars;

    for ( 1 .. $bars ) {
        $self->note( $self->eighth, $self->closed_hh, $self->kick );
        $self->note( $self->eighth, $self->closed_hh);
        $self->note( $self->eighth, $self->closed_hh, $self->snare );
    }
}

=head2 metronome34

  $d->metronome34;
  $d->metronome34($bars);

Add a steady 3/4 beat to the score.

=cut

sub metronome34 {
    my $self = shift;
    my $bars = shift || $self->bars;

    for ( 1 .. $bars ) {
        $self->note( $self->quarter, $self->ride1, $self->kick );
        $self->note( $self->quarter, $self->ride1 );
        $self->note( $self->quarter, $self->ride1, $self->snare );
    }
}

=head2 metronome44

  $d->metronome44;
  $d->metronome44($bars);
  $d->metronome44($bars, $flag);

Add a steady 4/4 beat to the score.

If a B<flag> is provided the beat is modified to include alternating
eighth-note kicks.

=cut

sub metronome44 {
    my $self = shift;
    my $bars = shift || $self->bars;
    my $flag = shift // 0;

    my $i = 0;

    for my $n ( 1 .. $self->beats * $bars ) {
        if ( $n % 2 == 0 )
        {
            $self->note( $self->quarter, $self->closed_hh, $self->snare );
        }
        else {
            if ( $flag == 0 )
            {
                $self->note( $self->quarter, $self->closed_hh, $self->kick );
            }
            else
            {
                if ( $i % 2 == 0 )
                {
                    $self->note( $self->quarter, $self->closed_hh, $self->kick );
                }
                else
                {
                    $self->note( $self->eighth, $self->closed_hh, $self->kick );
                    $self->note( $self->eighth, $self->kick );
                }
            }

            $i++;
        }
    }
}

=head2 metronome44swing

  $d->metronome44swing;
  $d->metronome44swing($bars);

Add a steady 4/4 swing beat to the score.

=cut

sub metronome44swing {
    my $self = shift;
    my $bars = shift || $self->bars;

    for my $n ( 1 .. $bars ) {
        $self->note( $self->quarter,          $self->ride1, $self->kick );
        $self->note( $self->triplet_eighth,   $self->ride1 );
        $self->rest( $self->triplet_eighth );
        $self->note( $self->triplet_eighth,   $self->ride1, $self->kick );
        $self->note( $self->quarter,          $self->ride1, $self->snare );
        $self->note( $self->triplet_eighth,   $self->ride1, $self->kick );
        $self->rest( $self->triplet_eighth );
        $self->note( $self->triplet_eighth,   $self->ride1 );
    }
}

=head2 metronome54

  $d->metronome54;
  $d->metronome54($bars);

Add a 5/4 beat to the score.

=cut

sub metronome54 {
    my $self = shift;
    my $bars = shift || $self->bars;
    for my $n (1 .. $bars) {
        $self->note($self->quarter, $self->closed_hh, $self->kick);
        $self->note($self->quarter, $self->closed_hh);
        $self->note($self->quarter, $self->closed_hh, $self->snare);
        $self->note($self->quarter, $self->closed_hh);
        if ($n % 2) {
            $self->note($self->quarter, $self->closed_hh);
        }
        else {
            $self->note($self->eighth, $self->closed_hh);
            $self->note($self->eighth, $self->kick);
        }
    }
}

=head2 metronome58

  $d->metronome58;
  $d->metronome58($bars);

Add a 5/8 beat to the score.

=cut

sub metronome58 {
    my $self = shift;
    my $bars = shift || $self->bars;
    for my $n (1 .. $bars) {
        $self->note($self->eighth, $self->closed_hh, $self->kick);
        $self->note($self->eighth, $self->closed_hh);
        $self->note($self->eighth, $self->closed_hh, $self->snare);
        $self->note($self->eighth, $self->closed_hh);
        $self->note($self->eighth, $self->closed_hh);
    }
}

=head2 metronome68

  $d->metronome68;
  $d->metronome68($bars);

Add a 6/8 beat to the score.

=cut

sub metronome68 {
    my $self = shift;
    my $bars = shift || $self->bars;
    for my $n (1 .. $bars) {
        $self->note($self->eighth, $self->closed_hh, $self->kick);
        $self->note($self->eighth, $self->closed_hh);
        $self->note($self->eighth, $self->closed_hh);
        $self->note($self->eighth, $self->closed_hh, $self->snare);
        $self->note($self->eighth, $self->closed_hh);
        $self->note($self->eighth, $self->closed_hh);
    }
}

=head2 metronome74

  $d->metronome74;
  $d->metronome74($bars);

Add a 7/4 beat to the score.

=cut

sub metronome74 {
    my $self = shift;
    my $bars = shift || $self->bars;
    for my $n (1 .. $bars) {
        $self->note($self->quarter, $self->closed_hh, $self->kick);
        $self->note($self->quarter, $self->closed_hh);
        $self->note($self->quarter, $self->closed_hh, $self->snare);
        $self->note($self->eighth, $self->closed_hh);
        $self->note($self->eighth, $self->kick);
        $self->note($self->quarter, $self->closed_hh, $self->kick);
        $self->note($self->quarter, $self->closed_hh, $self->snare);
        $self->note($self->quarter, $self->closed_hh);
    }
}

=head2 metronome78

  $d->metronome78;
  $d->metronome78($bars);

Add a 7/8 beat to the score.

=cut

sub metronome78 {
    my $self = shift;
    my $bars = shift || $self->bars;
    for my $n (1 .. $bars) {
        $self->note($self->eighth, $self->closed_hh, $self->kick);
        $self->note($self->eighth, $self->closed_hh);
        $self->note($self->eighth, $self->closed_hh);
        $self->note($self->eighth, $self->closed_hh, $self->kick);
        $self->note($self->eighth, $self->closed_hh, $self->snare);
        $self->note($self->eighth, $self->closed_hh);
        $self->note($self->eighth, $self->closed_hh);
    }
}

=head2 flam

  $d->flam($spec);
  $d->flam( $spec, $patch );

Add a "flam" to the score, where a ghosted 64th gracenote is played
before the primary note.

If not provided the B<snare> is used for the B<patch>.

=cut

sub flam {
    my ($self, $spec, $patch) = @_;
    $patch ||= $self->snare;
    my $x = $MIDI::Simple::Length{$spec};
    my $y = $MIDI::Simple::Length{ $self->sixtyfourth };
    my $z = sprintf '%0.f', ($x - $y) * TICKS;
    my $accent = sprintf '%0.f', $self->score->Volume / 2;
    $self->accent_note($accent, $self->sixtyfourth, $patch);
    $self->note('d' . $z, $patch);
}

=head2 roll

  $d->roll( $length, $spec );
  $d->roll( $length, $spec, $patch );

Add a drum roll to the score, where the B<patch> is played for
duration B<length> in B<spec> increments.

If not provided the B<snare> is used for the B<patch>.

=cut

sub roll {
    my ($self, $length, $spec, $patch) = @_;
    $patch ||= $self->snare;
    my $x = $MIDI::Simple::Length{$length};
    my $y = $MIDI::Simple::Length{$spec};
    my $z = sprintf '%0.f', $x / $y;
    $self->note($spec, $patch) for 1 .. $z;
}

=head2 crescendo_roll

  $d->crescendo_roll( [$start, $end, $bezier], $length, $spec );
  $d->crescendo_roll( [$start, $end, $bezier], $length, $spec, $patch );

Add a drum roll to the score, where the B<patch> is played for
duration B<length> in B<spec> notes, at increasing or decreasing
volumes from B<start> to B<end>.

If not provided the B<snare> is used for the B<patch>.

If true, the B<bezier> flag will render the crescendo with a curve,
rather than as a straight line.

     |            *
     |           *
 vol |         *
     |      *
     |*
     ---------------
           time

=cut

sub crescendo_roll {
    my ($self, $span, $length, $spec, $patch) = @_;
    $patch ||= $self->snare;
    my ($i, $j, $k) = @$span;
    my $x = $MIDI::Simple::Length{$length};
    my $y = $MIDI::Simple::Length{$spec};
    my $z = sprintf '%0.f', $x / $y;
    if ($k) {
        my $bezier = Math::Bezier->new(
            1, $i,
            $z, $i,
            $z, $j,
        );
        for (my $n = 0; $n <= 1; $n += (1 / ($z - 1))) {
            my (undef, $v) = $bezier->point($n);
            $v = sprintf '%0.f', $v;
#            warn(__PACKAGE__,' ',__LINE__," $n INC: $v\n");
            $self->accent_note($v, $spec, $patch);
        }
    }
    else {
        my $v = sprintf '%0.f', ($j - $i) / ($z - 1);
#        warn(__PACKAGE__,' ',__LINE__," VALUE: $v\n");
        for my $n (1 .. $z) {
            if ($n == $z) {
                if ($i < $j) {
                    $i += $j - $i;
                }
                elsif ($i > $j) {
                    $i -= $i - $j;
                }
            }
#            warn(__PACKAGE__,' ',__LINE__," $n INC: $i\n");
            $self->accent_note($i, $spec, $patch);
            $i += $v;
        }
    }
}

=head2 set_time_sig

  $d->set_time_sig('5/4');

Set the B<signature>, B<beats>, B<divisions>, and the B<score>
C<time_signature> values based on the given string.

=cut

sub set_time_sig {
    my $self = shift;
    if (@_) {
        $self->signature(shift);
    }
    my ($beats, $divisions) = split /\//, $self->signature;
    $self->beats($beats);
    $self->divisions($divisions);
    $self->score->time_signature(
        $self->beats,
        ( $self->divisions == 8 ? 3 : 2),
        ( $self->divisions == 8 ? 24 : 18 ),
        8
    );
}

=head2 sync

  $d->sync(@code_refs);

This is a simple pass-through to the B<score> C<synch> method.

This allows simultaneous playing of multiple "tracks" defined by code
references.

=cut

sub sync {
    my $self = shift;
    $self->score->synch(@_);
}

=head2 write

Output the score as a MIDI file with the module L</file> attribute as
the file name.

=cut

sub write {
    my $self = shift;
    $self->score->write_score( $self->file );
}

=head2 steady

  $d->steady;
  $d->steady( $d->kick );
  $d->steady( $d->kick, { duration => $d->eighth } );

Play a steady beat with the given B<instrument> and optional
B<duration> option, for the number of beats accumulated in the
object's B<counter> attribute.

Defaults:

  instrument: closed_hh
  Option:
    duration: quarter

=cut

sub steady {
    my ( $self, $instrument, $opts ) = @_;

    $instrument ||= $self->closed_hh;

    $opts->{duration} ||= $self->quarter;

    for my $n ( 1 .. $self->counter ) {
        $self->note( $opts->{duration}, $instrument );
    }
}

=head2 combinatorial

  $d->combinatorial;
  $d->combinatorial( $d->kick );
  $d->combinatorial( $d->kick, \%options );

Play a beat pattern with the given B<instrument>, given by
L<Algorithm::Combinatorics/variations_with_repetition>.

This method accumulates beats in the object's B<counter> attribute.

The B<vary> option is a hashref keyed by single character tokens, like
the digits, 0-9.  These should add up to the B<duration> option.

Defaults:

  instrument: snare
  Options:
    duration: quarter
    negate: 0
    beats: beats
    repeat: 4
    duration: quarter
    vary:
        0 => sub { $self->rest( $options->{duration} ) },
        1 => sub { $self->note( $options->{duration}, $instrument ) },
    patterns: undef

=cut

sub combinatorial {
    my ( $self, $instrument, $opts ) = @_;

    $instrument ||= $self->snare;

    $opts->{negate}   ||= 0;
    $opts->{beats}    ||= $self->beats;
    $opts->{repeat}   ||= 4;
    $opts->{duration} ||= $self->quarter;
    $opts->{vary}     ||= {
        0 => sub { $self->rest( $opts->{duration} ) },
        1 => sub { $self->note( $opts->{duration}, $instrument ) },
    };

    my @items = $opts->{patterns}
        ? $opts->{patterns}->@*
        : sort map { join '', @$_ }
            variations_with_repetition( [ keys $opts->{vary}->%* ], $opts->{beats} );

    for my $pattern (@items) {
        $pattern =~ tr/01/10/ if $opts->{negate};

        for ( 1 .. $opts->{repeat} ) {
            for my $bit ( split //, $pattern ) {
                $opts->{vary}{$bit}->();
                $self->counter( $self->counter + dura_size( $opts->{duration} ) );
            }
        }
    }
}

1;

__END__

=head1 SEE ALSO

The F<eg/*> programs in this distribution. Also
F<eg/drum-fills-advanced> in the L<Music::Duration::Partition>
distribution.

L<Algorithm::Combinatorics>

L<MIDI::Util>

L<Math::Bezier>

L<MIDI::Simple>

L<Moo>

L<Music::Duration>

L<https://en.wikipedia.org/wiki/General_MIDI#Percussion>

L<https://en.wikipedia.org/wiki/General_MIDI_Level_2#Drum_sounds>

L<https://www.amazon.com/dp/0882847953> -
"Progressive Steps to Syncopation for the Modern Drummer"

=cut
