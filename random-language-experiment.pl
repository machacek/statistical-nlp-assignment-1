#!/usr/bin/env perl

use strict;
use warnings;

use LanguageEntropy;

$\ = "\n";
$, = "\t";

my $vocsize = 100;
my $length = 10000000;

#generate random data
my @data;
foreach my $i (0..$length)
{
    push @data, int(rand($vocsize));
}

foreach my $i (0..7)
{
    my $tested_length = 10 ** $i;
    my @tested_data = @data[0..$tested_length];
    my $entropy = LanguageEntropy::conditionalEntropy(\@tested_data);
    print $tested_length, sprintf("%.3f", $entropy);
}
