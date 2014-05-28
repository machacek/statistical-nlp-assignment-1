package LanguageModel;

use strict;
use warnings;

use Tools;
use List::Util qw(first max maxstr min minstr reduce shuffle sum);
use Moose;

has 'ngram'      => ( isa => 'Int', is => 'ro' );
has 'vocSize'    => ( isa => 'Int', is => 'ro' );
has 'histSeen'   => ( isa => 'HashRef[Int]', is => 'ro' );
has 'parameters' => ( isa => 'HashRef[Num]', is => 'ro' );
has 'lambdas'    => ( isa => 'ArrayRef[Num]', is => 'rw' );

around BUILDARGS => sub {
    my $orig = shift;
    my $class = shift;
    my $n = shift;    

    my $tokensRef = shift;
    my @tokens = @{$tokensRef};

    my %parameters;
    my %histSeen;

    # Computing Vocabulary size
    my %vocub = map { $_ => 1 } @tokens;
    my $vocSize = keys(%vocub);

    # Computing zeroth order model
    $parameters{""} = 1 / $vocSize;

    # Computing n-th order models
    foreach my $i (1..$n)
    {
        my %counts;
        my %hcounts;

        my @history;
        foreach my $j (1..($i-1))
        {
            push @history, "<S>";
        }

        foreach my $token (@tokens)
        {
            my $jhistory = join " ", @history;

            $counts{ Tools::condEv( $token, $jhistory ) }++;
            $hcounts{ $jhistory }++;

            push @history, $token;
            shift @history;
        }
        
        foreach my $condEv (keys %counts)
        {
            $parameters{ $condEv } = $counts{ $condEv } / $hcounts{ Tools::history($condEv) };
        }

        foreach my $history (keys %hcounts)
        {
            $histSeen{ $history } = $hcounts{ $history };
        }
    }

    # Creating initial lambdas
    my @lambdas;
    foreach my $i (0..$n)
    {
        push @lambdas, 1/($n+1);
    }

    # Creating hash for constructor
    return {
        ngram       => $n,
        vocSize     => $vocSize,
        histSeen    => \%histSeen,
        parameters  => \%parameters,
        lambdas     => \@lambdas,
    };
};

sub prob
{
    my $self = shift;
    my $item = shift;
    my $hist = join " ", @_;

    if (exists $self->histSeen()->{ $hist })
    {
        if (exists $self->parameters()->{ Tools::condEv($item, $hist) })
        {
            return $self->parameters()->{ Tools::condEv($item, $hist) };
        }
        else 
        {
            return 0;
        }
    }
    else
    {
        return 1 / $self->vocSize();
    }
}

sub interpolatedProb
{
    my $self    = shift;
    my $item    = shift;
    my @history = @_;

    my $score   = 0;
    
    # Zeroth order model
    $score += $self->lambdas()->[0] * $self->parameters()->{""};
    
    # N-th order model
    foreach my $i (1..$self->ngram())
    {
        # history of size $i-1:
        my @history_i = @history[(-$i+1)..-1];
        
        $score += $self->lambdas()->[$i] * $self->prob($item, @history_i);
    }

    return $score;
}

sub crossEntropy
{
    my $self     = shift;
    my $testRef  = shift;

    my @test     = @{$testRef};
    my $testSize = @test;

    my $sum = 0;

    my @hist;
    foreach my $i (1..$self->ngram()-1)
    {
        push @hist, "<S>";
    }

    foreach my $token (@test)
    {
        $sum += Tools::log2( $self->interpolatedProb($token, @hist) );

        push @hist, $token;
        shift @hist;
    }


    return -1 * $sum / $testSize;
}

sub trainLambdas
{
    my $self       = shift;
    my $heldoutRef = shift;

    my @heldout = @{ $heldoutRef };

    my $epsilon = 0.001;

    # Debug output
    print STDERR "Starting Smoothing EM Algorithm";
    print STDERR "Actual Lambdas: ", @{$self->lambdas()};
    print STDERR "Actual Cross Entropy: ", $self->crossEntropy($heldoutRef);

    my $done = 0;
    my $iteration = 0;

    while (not $done)
    {
        $iteration++;
        print STDERR "\nStarting iteration $iteration";

        # Prepare array for new lambdas
        my @newLambdas;
        foreach my $i (0..$self->ngram())
        {
            push @newLambdas, 0;
        }

        # Prepare history array
        my @hist;
        foreach my $i (1..$self->ngram()-1)
        {
            push @hist, "<S>";
        }
        
        # Iterate heldout data
        foreach my $token (@heldout)
        {
            # Update each lambda
            foreach my $i (0..$self->ngram())
            {
                if ($i eq 0)
                {
                    $newLambdas[$i] += $self->parameters()->{""} / $self->interpolatedProb($token,@hist);
                }
                else
                {
                    # history of size $i-1:
                    my @limitedHist = @hist[(-$i+1)..-1];
                    $newLambdas[$i] += $self->prob($token,@limitedHist) / $self->interpolatedProb($token,@hist);
                }
            }
            
            # Update history for next iteration
            push @hist, $token;
            shift @hist;
        }

        # Multiply with old lambdas
        foreach my $i (0..$#newLambdas)
        {
            $newLambdas[$i] *= $self->lambdas()->[$i];
        }

        # We have to normalize Lambdas
        my $sum = sum(@newLambdas);
        @newLambdas = map { $_/$sum } @newLambdas;

        # Check if some parameter change significantly and continue in next iteration
        $done = 1;
        foreach my $i (0..$self->ngram())
        {
            if ( abs( $newLambdas[$i] - $self->lambdas()->[$i]) > $epsilon)
            {
                $done = 0;
            }
        }

        # Apply new Lambdas
        $self->lambdas(\@newLambdas);

        # Debug output
        print STDERR "New Lambdas: ", @{$self->lambdas()};
        print STDERR "New Cross Entropy: ", $self->crossEntropy($heldoutRef);
    }

    print STDERR "End of EM Smoothing Algorithm";
}

sub normalizeLambdas
{
    my $self = shift;
    my @lambdas = @{ $self->lambdas() };

    my $sum = sum(@lambdas);
    @lambdas = map { $_/$sum } @lambdas;
    $self->lambdas(\@lambdas);
}

sub tweakLambda
{
    my $self = shift;
    my $newValue = shift;
    my $index = shift;

    my @lambdas = @{ $self->lambdas() };

    my $oldRestSum = sum(@lambdas) - $lambdas[$index];
    my $newRestSum = sum(@lambdas) - $newValue;
    my $rate = $newRestSum / $oldRestSum;

    $lambdas[$index] = $newValue;

    foreach my $i (0..$#lambdas)
    {
        if ($i ne $index)
        {
            $lambdas[$i] *= $rate;
        }
    }

    $self->lambdas(\@lambdas);
}

sub dump
{
    my $self = shift;

    Tools::dumpScalar("ngram", $self->ngram());
    Tools::dumpScalar("vocSize", $self->vocSize());
    Tools::dumpHash("histSeen", $self->histSeen());
    Tools::dumpHash("parameters", $self->parameters());
    Tools::dumpArray("lambdas", $self->lambdas());
}

1;
