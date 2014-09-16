use 5.010;
use strict;
use warnings;

no warnings 'redefine';

use Benchmark qw(timethese);
use JSON::Decode::Marpa ();
use JSON::Decode::Regexp ();
use JSON::XS ();
use JSON::PP ();
use Pegex::JSON;
use MarpaX::Languages::ECMAScript::AST;
use MarpaX::JSON;

my @json = ();
push @json, q([1,"abc\ndef",-2.3,null,[],[1,2,3],{},{"a":1,"b":2}]) for 1 .. 1000;
my $json = '[' . ( join q{,}, @json) . ']';

my $pgx     = Pegex::JSON->new;
my $p       = MarpaX::JSON->new;
my $ecmaAst = MarpaX::Languages::ECMAScript::AST->new();
my $JSON    = $ecmaAst->JSON;

timethese -10, {
    'Pegex::JSON'          => sub { $pgx->load($json) },
    'JSON::Decode::Regexp' => sub { JSON::Decode::Regexp::from_json($json) },
    'Marpa::R2'            => sub { JSON::Decode::Marpa::from_json($json) },
    'JSON::XS'             => sub { JSON::XS::decode_json($json) },
    'JSON::PP'             => sub { JSON::PP::decode_json($json) },
    'MarpaX::Languages::ECMAscript::AST' => sub {
        my $parse = $JSON->{grammar}->parse( $json, $JSON->{impl} );
        my $value = eval { $JSON->{grammar}->value( $JSON->{impl} ) };
        },
    'MarpaX::JSON'         => sub { $p->parse_json($json) },
};
