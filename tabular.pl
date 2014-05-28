#!/usr/bin/env perl

use strict;
use warnings;

$\ = " \\\\\n";
$, = " & ";
#$" = "\t";

while (my $line = <>)
{
    chomp $line;
    my @cells = split /\t/, $line;
    print @cells;
}

1;
