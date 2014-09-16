use 5.010;
use strict;
use warnings;

select((select(STDOUT), $|=1)[0]);
select((select(STDERR), $|=1)[0]);

use Benchmark qw(timeit timestr);
use Memory::Usage;

use MarpaX::JSON;
#use MarpaX::Languages::ECMAScript::AST;
use JSON::PP;
#use JSON::XS;
use JSON::Decode::Marpa ();
use JSON::Decode::Regexp ();

my $json;

sub gen_json{
    my $n = shift;
    my @json = ();
    push @json, q([1,"abc\ndef",-2.3,null,[],[1,2,3],{},{"a":1,"b":2}]) for 1 .. $n;
    $json = '[' . ( join q{,}, @json) . ']';
}

my $j       = MarpaX::JSON->new;
#my $ecmaAst = MarpaX::Languages::ECMAScript::AST->new();
#my $JSON    = $ecmaAst->JSON;

my $parsers = {
#    'MarpaX::Languages::ECMAScript::AST' =>  sub {
#        my $parse = $JSON->{grammar}->parse( $json, $JSON->{impl} );
#        my $value = eval { $JSON->{grammar}->value( $JSON->{impl} ) };
#    },
#    'JSON::Decode::Regexp' => sub { JSON::Decode::Regexp::from_json($json) },
    'MarpaX::JSON'          => sub { $j->parse_json($json) },
#    'JSON::Decode::Marpa'   => sub { JSON::Decode::Marpa::from_json($json) },
    'JSON::PP'              => sub { JSON::PP::decode_json($json) },
};

my $count   = 3;

my $min     = 1;
my $max     = 10; # JSON::Decode::Regexp goes out of memory at 560001 under cygwin
my $step    = 0.5;

my $base    = exp(1);
my $scale   = 25;

my $times = { map { $_ => { 'len' => [], 'cpu_p' => [] } } keys %$parsers };

my $json_length_limit = 600000;

for my $k (sort keys %$parsers){
    say $k;
    my $len = $times->{$k}->{'len'};
    my $cpu_p = $times->{$k}->{'cpu_p'};
    for (my $power = $min; $power <= $max; $power += $step){
        
        # (base ** power)
        # power-law growth:     
        #   base ** power
        #       power = max..min, step
        #       base = max..min, step
        #   exponential growth:   base = 2 (or e)
        #   quadratic growth:     power = 2, base = max..min, step
        my $n = $base ** $power * $scale;
        gen_json( $n ); # $json global will be set
        my $json_length = length $json;
        
        printf "%f %8d %10d %4d ... ", $power, $n, $json_length, $count;
        
#        if (exists $parsers->{'JSON::Decode::Regexp'} and $json_length >= $json_length_limit){
#            say "json length $json_length at power $power exceeds limit, exiting the loop";
#            last;
#        }
        
        my $t = timeit ( $count, $parsers->{ $k } );
        printf " %f s\n", $t->cpu_p;
        
        push @$len, $json_length;
        push @$cpu_p, $t->cpu_p;
    }
    say '';
}

# 

#use YAML;
#say Dump $times;

use Statistics::LineFit;

for my $k (sort keys %$parsers){

    my $len = $times->{$k}->{'len'};
    my $cpu_p = $times->{$k}->{'cpu_p'};

    my $lineFit = Statistics::LineFit->new();
    $lineFit->setData ($cpu_p, $len) or die "Invalid data";
    my $rSquared = $lineFit->rSquared();
    
    say "$k: $rSquared";
}

=pod Testing Time and Space Complexity

    Select input size interval and iteration step

    exponential growth
    
    Sequitur -- linear
    Bubble sort -- quadratic
        simple bubble sort in perl 
        http://www.perlmonks.org/?node_id=113259
    binary search -- logarithmic

fitting modules
    Math::GSL::Fit
    https://metacpan.org/pod/Algorithm::CurveFit
    
=cut
