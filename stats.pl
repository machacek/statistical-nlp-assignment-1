#!/usr/bin/env perl

use strict;
use warnings;

$\ = "\n";
$, = "\t";

my @data = map { chomp $_; $_ } <>;

my %hash = map { $_ => 1 } @data;
my @set = keys %hash;

my $size = int(@data);
my $vocSize = int(@set);
my $rate = $size / $vocSize;

my $chars = join '', @data;
my @chars = split //, $chars;

%hash = map { $_ => 1 } @chars;
@set = keys %hash;

my $charSize =  int(@chars);
my $charVobSize = int(@set);
my $charsPerWord = $charSize / $size;

my %counts;
my $count = 0;
foreach my $word (@data)
{
    $counts{ $word }++;
    $count++;
}

my @sorted = sort { $counts{$a} <=> $counts{$b} } keys %counts;
my $bestFreq = $counts{ $sorted[0] } / $count;

my $oneCount = 0;
foreach my $key (keys %counts)
{
    if ($counts{$key} eq 1)
    {
        $oneCount++;
    }
}
$oneCount /= $vocSize;

print "word count", $size;
print "vocabulary size", $vocSize;
print "word count / vocabulary size", sprintf("%.3f", $rate);
print "character count", $charSize;
print "alphabet size", $charVobSize;
print "average characters in word", sprintf("%.3f", $charsPerWord);
print "frequency of most frequent word", sprintf("%.3f", $bestFreq); 
print "percent of words seen only once", sprintf("%.3f", $oneCount);

#my %countOfCounts;
#foreach my $word (keys %counts)
#{
#    $countOfCounts{ $counts{$word} }++;
#}
#foreach my $key (sort {$a <=> $b} keys %countOfCounts)
#{
#    print STDERR $countOfCounts{ $key }, "slov ma frekvenci", $key;
#}
