#!/usr/bin/env perl

use strict;
use warnings;

use LanguageEntropy;
use List::Util qw(first max maxstr min minstr reduce shuffle sum);

$\ = "\n";
$, = "\t";

# Process command line argument
my $changeWords;
if ($ARGV[0] eq "words")
{
    $changeWords = 1;
}
elsif ($ARGV[0] eq "chars")
{
    $changeWords = 0;
}
else
{
    die "First argument has to be \"words\" or \"chars\".";
}

# Read corpus into memory
my @corpus = map { chomp $_; $_ } <STDIN>;

# Compute entropies with changed words/chars
#my @likelihoods = (50, 100);
my @likelihoods = (0, 0.001, 0.01, 0.1, 1, 5, 10, 20);
foreach my $likelihood (@likelihoods)
{
    my ($min, $avg, $max) = computeAvg(\@corpus, $likelihood);
    print $likelihood, sprintf("%.3f", $min), sprintf("%.3f", $avg), sprintf("%.3f", $max);
}


sub computeAvg
{
    my $data_ref = shift;
    my $prob = shift;

    my @entropies;

    my $n = 10;
    foreach my $i (1..$n)
    {
        # Prepare random generator
        srand($i*$prob);

        # Change words/chars with the given probability
        my $changed_ref;
        if ($changeWords)
        {
            $changed_ref = LanguageEntropy::changeWords($data_ref, $prob);
        }
        else
        {
            $changed_ref = LanguageEntropy::changeChars($data_ref, $prob);
        }
        
        # Compute entropy
        my $entropy = LanguageEntropy::conditionalEntropy($changed_ref);
        push @entropies, $entropy;
    }

    my $avg = sum(@entropies) / int(@entropies);
    my $min = min(@entropies);
    my $max = max(@entropies);

    return ($min, $avg, $max)    
}
