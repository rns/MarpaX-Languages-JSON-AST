#!/usr/bin/perl
# Copyright 2013 Jeffrey Kegler
# This file is part of Marpa::R2.  Marpa::R2 is free software: you can
# redistribute it and/or modify it under the terms of the GNU Lesser
# General Public License as published by the Free Software Foundation,
# either version 3 of the License, or (at your option) any later version.
#
# Marpa::R2 is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser
# General Public License along with Marpa::R2.  If not, see
# http://www.gnu.org/licenses/.

# Test using a JSON parser
# Inspired by a parser written by Peter Stuifzand

use 5.010;
use strict;
use warnings;
use Test::More;

use_ok('MarpaX::Languages::JSON::AST::Test');

my $t = MarpaX::Languages::JSON::AST::Test->new;

use JSON::PP;

use Data::Dumper;
$Data::Dumper::Useqq = 1;
$Data::Dumper::Indent = 0;
$Data::Dumper::Terse = 1;

for my $test (@{ $t->tests }){
    my ($json, $dump) = @$test;

    my $got_json;
    eval { $got_json = decode_json($json) };
    my $e = $@;
    
    use Text::Diff;
    if ($e){
        $dump =~ s/^Parse Error: //;
        my $result = index ($e, $dump) >= 0;
        ok $result, "<$json> parsing failed";
        say diff \$dump, \$e unless $result;
    }
    else{
        my $dump_json = Dumper($got_json);
        # patch 
        $dump_json =~ bless( do{\(my $o = 1)}, 'JSON::PP::Boolean' );
        my $result = $dump eq $dump_json;
        ok $result, "<$json> parsed";
        say diff \$dump_json, \$dump unless $result;
    }
}

done_testing;

1;
