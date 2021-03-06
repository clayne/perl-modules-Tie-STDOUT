#!/usr/bin/perl

use strict;
use warnings;

use Test::More;

use Config;
use File::Temp;

local $/ = undef;

test_fragment(
    q{ print qq{foo\n}; print qq{bar\n}; },
    "foo\nbar\n",
    "default 'print' works OK"
);

test_fragment(
    q{ printf qq{%s %d\n}, qq{foo}, 20; },
    "foo 20\n",
    "default 'printf' works OK"
);

test_fragment(
    q{ syswrite STDOUT, qq{gibberish}, 5; },
    "gibbe",
    "default 'syswrite' works with no offset"
);

test_fragment(
    q{ syswrite STDOUT, qq{gibberish}, 5, 2; },
    "bberi",
    "default 'syswrite' works with an offset"
);

done_testing();

sub test_fragment {
    my($fragment, $expected, $message) = @_;

    my $tempfile = File::Temp::tempnam('.', 'tie-stdout-test-');
    my $preamble = join(' ',
        $Config{perlpath},
        ($ENV{HARNESS_PERL_SWITCHES} && $ENV{HARNESS_PERL_SWITCHES} eq '-MDevel::Cover' ? '-MDevel::Cover' : ''),
        qw(-Ilib -MTie::STDOUT -e ")
    );
    my $postamble = "\" >$tempfile";

    system($preamble.$fragment.$postamble);
    open(FILE, $tempfile);
    is(<FILE>, $expected, $message);
    unlink($tempfile);
}
