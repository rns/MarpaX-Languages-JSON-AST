use 5.010;
use strict;
use warnings;

my $x = [];
my $y = [];

my $min = 0;
my $max = 10;
my $step = 1;

for (my $v = $min; $v <= $max; $v += $step){
    push @$x, $v;
    push @$y, $v ** 3 / 100000;
}

for my $i (0..@$x-1){
    say "$x->[$i] $y->[$i]";
}

use Statistics::LineFit;
my $lineFit = Statistics::LineFit->new();
$lineFit->setData ($y, $x) or die "Invalid data";
my $rSquared = $lineFit->rSquared();

say $rSquared;


