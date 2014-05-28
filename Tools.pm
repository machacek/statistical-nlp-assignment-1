package Tools;

use strict;
use warnings;

sub history
{
    my $bigram = shift;
    my @split = split /\|/, $bigram;
    if (not defined $split[1])
    {
        return "";
    }
    else
    {
        return $split[1];
    }
}

sub condEv
{
    my $item = shift;
    my $history = shift;
    return $item . "|" . $history;
}

sub ngram
{
    return join " ", @_;
}

sub bigram
{
    my $left = shift;
    my $right = shift;
    return $left . " " . $right;
}

sub left
{
    my $bigram = shift;
    my @split = split " ", $bigram;
    return $split[0];
}

sub right
{
    my $bigram = shift;
    my @split = split " ", $bigram;
    return $split[1];
}

sub log2
{
    my $n = shift;
    return log($n)/log(2);
}

sub dumpHash
{
    my $name = shift;
    my $hashRef = shift;

    my %hash = %$hashRef;

    $, = " ";
    $\ = "\n";

    print $name, "= {";
    foreach my $key (sort keys(%hash))
    {
        my $spaces = "";
        foreach my $i (1..(15-length($key)))
        {
            $spaces = $spaces . " ";
        }

        print "\t",$key, $spaces, "=>", $hash{$key};
    }
    print "}";
}

sub dumpArray
{
    my $name = shift;
    my $arrayRef = shift;

    my @array = @$arrayRef;

    $, = " ";
    $\ = "\n";

    print "$name =", @array;
}

sub dumpScalar
{
    my $name = shift;
    my $value = shift;

    $, = " ";
    $\ = "\n";

    print $name, "=", $value;
}

1;
