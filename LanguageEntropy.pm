package LanguageEntropy;

use strict;
use warnings;

use Tools;

sub conditionalEntropy
{
    my $data_ref = shift;

    my ($joint, $conditional) = computeProbabilities($data_ref);
    
    my $sum = 0;
    for my $bigram (keys %{$joint})
    {
        $sum += $joint->{ $bigram }  *  Tools::log2( $conditional->{ $bigram } );
    }

    return -$sum;
}

sub computeProbabilities
{
    my $data_ref = shift;
    my @data = @$data_ref;
    
    my %bigrams;
    my %history;
    my $count;

    my $i = "<S>";

    foreach my $j (@data)
    {
        $bigrams{ Tools::bigram($i,$j) }++;
        $history{$i}++;
        $count++;
        $i = $j;
    }

    my %joint;
    my %conditional; # XXX Pravdepodobnost p(j|i) je ulozena v klici "i j", tedy v obracenem poradi

    for my $bigram (keys %bigrams)
    {
        $joint{ $bigram }       = $bigrams{ $bigram } / $count;
        $conditional{ $bigram } = $bigrams{ $bigram } / $history{ Tools::left($bigram) }
    }

    return \%joint, \%conditional;
}

sub changeWords
{
    my $array_ref = shift;
    my $prob = shift;

    my @array = @$array_ref;
    my @set = @{setOfWords($array_ref)};

    foreach my $word (@array)
    {
        if (randomBool($prob))
        {
            $word = $set[int(rand(@set))];
        }
    }

    return \@array;
}

sub changeChars
{
    my $array_ref = shift;
    my $prob = shift;

    my @array = @$array_ref;
    my @set = @{setOfChars($array_ref)};

    foreach my $word (@array)
    {
        my @chars = split //, $word;
        foreach my $char (@chars)
        {
            if (randomBool($prob))
            {
                $char = $set[int(rand(@set))];
            }
        }
        $word = join '', @chars;
    }
    return \@array;
}

sub setOfWords
{
    my $array_ref = shift;
    my %set = map { $_ => 1 } @$array_ref;
    my @set = keys %set;
    return \@set;
}

sub setOfChars
{
    my $array_ref = shift;

    my %charset;
    foreach my $word (@$array_ref)
    {
        foreach my $char (split(//, $word))
        {
            $charset{$char} = 1;
        }
    }
    my @charset = keys %charset;
    return \@charset;
}

sub randomBool
{
    my $treshold = shift;
    if (rand(100) < $treshold)
    {
        return 1;
    }
    else
    {
        return 0;
    }
}

1;
