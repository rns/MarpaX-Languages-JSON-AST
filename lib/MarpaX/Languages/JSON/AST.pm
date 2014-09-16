#!/usr/bin/perl
# Copyright 2014 Jeffrey Kegler
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

package MarpaX::Languages::JSON::AST;

use 5.010;
use strict;
use warnings;

use Marpa::R2;

sub new {

    my ($class) = @_;

    my $parser = bless {}, $class;
    
    $parser->{grammar} = Marpa::R2::Scanless::G->new(
        {
            source         => \(<<'END_OF_SOURCE'),

            :default     ::= action => [name, value]
            lexeme default = action => [name, value]

            json         ::= object 
                           | array

            object       ::= ('{' '}')
                           | ('{') members ('}')

            members      ::= pair*                  separator => [,]

            pair         ::= string (':') value

            value        ::= string
                           | object
                           | number
                           | array
                           | 'true' 
                           | 'false'
                           | 'null' 


            array        ::= ('[' ']')
                           | ('[') elements (']') 

            elements     ::= value+                 separator => [,]

            number         ~ int
                           | int frac
                           | int exp
                           | int frac exp

            int            ~ digits
                           | '-' digits

            digits         ~ [\d]+

            frac           ~ '.' digits

            exp            ~ e digits

            e              ~ 'e'
                           | 'e+'
                           | 'e-'
                           | 'E'
                           | 'E+'
                           | 'E-'

            string       ::= lstring

            lstring        ~ quote in_string quote
            quote          ~ ["]
            in_string      ~ in_string_char*
            in_string_char ~ [^"] | '\"'

            :discard       ~ whitespace
            whitespace     ~ [\s]+

END_OF_SOURCE
        }
    );

    return $parser;
}

sub parse {
    my ( $parser, $string ) = @_;

    my $re = Marpa::R2::Scanless::R->new(
        {   grammar           => $parser->{grammar},
        }
    );
    $re->read( \$string );
    my $ast = ${ $re->value() };
    return $parser->decode ( $ast );
} ## end sub parse

sub decode {
    my $parser = shift;
    
    my $ast  = shift;
    
    if (ref $ast){
        my ($id, @nodes) = @$ast;
        if ($id eq 'json'){
            $parser->decode(@nodes);
        }
        elsif ($id eq 'members'){
            return { map { $parser->decode($_) } @nodes }; 
        }
        elsif ($id eq 'pair'){
            return map { $parser->decode($_) } @nodes; 
        }
        elsif ($id eq 'elements'){
            return [ map { $parser->decode($_) } @nodes ]; 
        }
        elsif ($id eq 'string'){
            return decode_string( substr $nodes[0]->[1], 1, -1 );
        }
        elsif ($id eq 'number'){
            return $nodes[0];
        }
        elsif ($id eq 'object'){
            return {} unless @nodes;
            return $parser->decode($_) for @nodes; 
        }
        elsif ($id eq 'array'){
            return [] unless @nodes;
            return $parser->decode($_) for @nodes; 
        }
        else{
            return $parser->decode($_) for @nodes; 
        }
    }
    else
    {
        if ($ast eq 'true' or $ast eq 'false'){ return $ast eq 'true' }
        elsif ($ast eq 'null' ){ return undef }
        else { warn "unknown scalar <$ast>"; return $ast }
    }
}

sub parse_json {
    my ($parser, $string) = @_;
    return $parser->parse($string);
}

sub decode_string {
    my ($s) = @_;
    
    $s =~ s/\\u([0-9A-Fa-f]{4})/chr(hex($1))/egxms;
    $s =~ s/\\n/\n/gxms;
    $s =~ s/\\r/\r/gxms;
    $s =~ s/\\b/\b/gxms;
    $s =~ s/\\f/\f/gxms;
    $s =~ s/\\t/\t/gxms;
    $s =~ s/\\\\/\\/gxms;
    $s =~ s{\\/}{/}gxms;
    $s =~ s{\\"}{"}gxms;

    return $s;
} ## end sub decode_string

1;
