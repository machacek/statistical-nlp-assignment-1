#!/usr/bin/env perl

use strict;
use warnings;

use LanguageModel;

$\ = "\n";
$, = " ";

# Load corpus into memory
my @corpus      = map { chomp $_; $_ } <>;

# Divide corpus to parts
my @TrainData   = @corpus[0..($#corpus-60000)];
print STDERR "Train data loaded:", scalar @TrainData, "tokens";

my @HeldOutData = @corpus[-60000..-20001];
print STDERR "Heldout data loaded:", scalar @HeldOutData, "tokens";

my @TestData    = @corpus[-20000..-1];
print STDERR "Test data loaded:", scalar @TestData, "tokens";

# Create trigram language model from train data
print STDERR "Creating language model";
my $lm = LanguageModel->new(3,\@TrainData);

# Train lambdas (EM algorithm)

# Train lambdas using train data
print STDERR "\n===============================================================================\n";
print STDERR "Training Lambdsas on train data";
$lm->trainLambdas(\@TrainData);
print STDERR "TestData CrossEntropy:", $lm->crossEntropy(\@TestData);


# Train lambdas using heldout data
print STDERR "\n===============================================================================\n";
print STDERR "Training Lambdsas on heldout data";
$lm->trainLambdas(\@HeldOutData);
print STDERR "TestData CrossEntropy:", $lm->crossEntropy(\@TestData);

# Tweaking lambda
print STDERR "\n===============================================================================\n";

my @trained_lambdas = @{$lm->lambdas()};
my $lambda3 = $trained_lambdas[3];
my $toOne = 1 - $lambda3;

my @prop1 = (0, 10, 20, 30, 40, 50, 60, 70, 80, 90, 100);
my @prop2 = (10, 20, 30, 40, 50, 60, 70, 80, 90, 95, 99);

my @tweaked1 = map { ($_/100) * $lambda3 } @prop1;
my @tweaked2 = map { $lambda3 + ($_/100) * $toOne } @prop2;
my @tweaked = (@tweaked1,@tweaked2);

$, = "\t";
foreach my $newLambda3 (@tweaked)
{
    $lm->tweakLambda($newLambda3, 3);
    my $crossEntropy = $lm->crossEntropy(\@TestData);
    print sprintf("%.3f", $newLambda3), sprintf("%.3f", $crossEntropy);
    $lm->lambdas(\@trained_lambdas);
}

