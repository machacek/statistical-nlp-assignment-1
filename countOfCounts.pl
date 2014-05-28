#!/usr/bin/env perl

use strict;
use warnings;

$\ = "\n";
$, = "\t";

my @data = map { chomp $_; $_ } <>;

my %counts;
foreach my $word (@data)
{
    $counts{ $word }++;
}

my %countOfCounts;
foreach my $word (keys %counts)
{
    $countOfCounts{ $counts{$word} }++;
}
foreach my $key (sort {$a <=> $b} keys %countOfCounts)
{
    print $key, $countOfCounts{ $key };
}
