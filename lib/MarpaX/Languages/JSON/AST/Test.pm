package MarpaX::Languages::JSON::AST::Test;

use 5.010;
use strict;
use warnings;

use Marpa::R2;

sub new {
    my ($class) = @_;
    my $self = bless {}, $class;

    # read test lines
    my @l = grep {!/^#/} map { chomp; $_ } <DATA>;
    my @tests;
    while (my ($json, $dump) = splice( @l, 0, 2 )) {
        push @tests, [ $json, $dump ];
    }
    $self->{tests} = \@tests;
#    use Data::Dumper::Concise;
#    say Dumper $self->{tests};
    return $self;
}

sub tests{ $_[0]->{tests} }

sub run_one_liner_tests{
    
    my $self = shift;
    
    my $decode_sub = shift;
    
}

1;
__DATA__
#   json
#   dump of decode(json) of JSON::XS or JSON::XS parse error or empty line denoting undef
{"test":"1"}
{"test" => 1}
{"test":[1,2,3]}
{"test" => [1,2,3]}
{"test":true}
{"test" => 1 }
{"test":false}
{"test" => 0 }
{"test":null}
{"test" => undef}
{"test":null, "test2":"hello world"}
{"test" => undef,"test2" => "hello world"}
{"test":"1.25"}
{"test" => "1.25"}
{"test":"1.25e4"}
{"test" => "1.25e4"}
[]
[]
{}
{}
{ "test":  "\u2603" }
{"test" => "\x{2603}"}
# JSON::XS one liners
"?"
Parse Error: JSON text must be an object or array (but found number, string, true, false or null, use allow_nonref to allow this)
"\u00fc"
Parse Error: JSON text must be an object or array (but found number, string, true, false or null, use allow_nonref to allow this)
{ "test":   "\"\n\\\\\r\t\f\b" }
{"test" => "\"\n\\\\\r\t\f\b"}
"\u1234\udc00"
Parse Error: missing high surrogate character in surrogate pair, at character offset 13 (before """)
\ud800
Parse Error: missing low surrogate character in surrogate pair, at character offset 7 (before """)
"\ud800\u1234"
Parse Error: surrogate pair expected, at character offset 13 (before """)
null
Parse Error: JSON text must be an object or array (but found number, string, true, false or null, use allow_nonref to allow this)
+0
Parse Error: malformed JSON string, neither tag, array, object, number, string or atom, at character offset 0 (before "+0")
.2
Parse Error: malformed JSON string, neither tag, array, object, number, string or atom, at character offset 0 (before ".2")
bare
Parse Error: malformed JSON string, neither tag, array, object, number, string or atom, at character offset 0 (before "bare")
naughty
Parse Error: 'null' expected, at character offset 0 (before "naughty")
01
Parse Error: malformed number (leading zero must not be followed by another digit), at character offset 1 (before "1")
00
Parse Error: malformed number (leading zero must not be followed by another digit), at character offset 1 (before "0")
-0.
Parse Error: malformed number (no digits after decimal point), at character offset 3 (before "(end of string)")
-0e
Parse Error: malformed number (no digits after exp sign), at character offset 3 (before "(end of string)")
-e+1
Parse Error: malformed number (no digits after initial minus), at character offset 1 (before "e+1")
"\"\n\""
Parse Error: JSON text must be an object or array (but found number, string, true, false or null, use allow_nonref to allow this)
"\"\x01\""
Parse Error: illegal backslash escape sequence in string, at character offset 3 (before "\\x01\\""")
[5
Parse Error: , or ] expected while parsing array, at character offset 2 (before "(end of string)")
{"5"
Parse Error: ':' expected, at character offset 4 (before "(end of string)")
{"5":null
Parse Error: , or } expected while parsing object/hash, at character offset 9 (before "(end of string)")
undef
Parse Error: malformed JSON string, neither tag, array, object, number, string or atom, at character offset 0 (before "undef")
\5
Parse Error: malformed JSON string, neither tag, array, object, number, string or atom, at character offset 0 (before "\\5")
[]
[]
"\"\xa0"
Parse Error: illegal backslash escape sequence in string, at character offset 3 (before "\\xa0"")
"\"\xa0\""
Parse Error: illegal backslash escape sequence in string, at character offset 3 (before "\\xa0\\""")
5
Parse Error: JSON text must be an object or array (but found number, string, true, false or null, use allow_nonref to allow this)
-5
Parse Error: JSON text must be an object or array (but found number, string, true, false or null, use allow_nonref to allow this)
5e1
Parse Error: JSON text must be an object or array (but found number, string, true, false or null, use allow_nonref to allow this)
-333e+0
Parse Error: JSON text must be an object or array (but found number, string, true, false or null, use allow_nonref to allow this)
2.5
Parse Error: JSON text must be an object or array (but found number, string, true, false or null, use allow_nonref to allow this)
{"var1":"val1","var2":["first_element",{"sub_element":"sub_val","sub_element2":"sub_val2"}],"var3":"val3"}
{"var3" => "val3","var1" => "val1","var2" => ["first_element",{"sub_element2" => "sub_val2","sub_element" => "sub_val"}]}
{"id":"abc\ndef"}
{"id" => "abc\ndef"}
{"id":"abc\\\ndef"}
{"id" => "abc\\\ndef"}
{"id":"abc\\\\\ndef"}
{"id" => "abc\\\\\ndef"}
{"foo":0}
{"foo" => 0}
{"foo":0.1}
{"foo" => "0.1"}
{"foo":10}
{"foo" => 10}
{"foo":-10}
{"foo" => -10}
{"foo":0, "bar":0.1}
{"bar" => "0.1","foo" => 0}
[]
[]
[{}]
[{}]
[{"a":6}]
[{"a" => 6}]
[{"a":4,"b":7}]
[{"a" => 4,"b" => 7}]
[{"a":4,"b":7}]
[{"a" => 4,"b" => 7}]
[{"a":3}]
[{"a" => 3}]
[{"a":4,"b":7}]
[{"a" => 4,"b" => 7}]
[{"a":9}]
[{"a" => 9}]
[{"a":4}]
[{"a" => 4}]
[{"a":4}]
[{"a" => 4}]
"\"\\u0012\x{89}\""
Parse Error: illegal backslash escape sequence in string, at character offset 10 (before "\\x{89}\\""")
\"\\u0012\x{89}\\u0abc\"
\x{12}\x{89}\x{abc}
"[] "
Parse Error: JSON text must be an object or array (but found number, string, true, false or null, use allow_nonref to allow this)
"[] x"
Parse Error: JSON text must be an object or array (but found number, string, true, false or null, use allow_nonref to allow this)
"[][]"
Parse Error: JSON text must be an object or array (but found number, string, true, false or null, use allow_nonref to allow this)
"[1] t"
Parse Error: JSON text must be an object or array (but found number, string, true, false or null, use allow_nonref to allow this)
[1,2, 3,4,,]
Parse Error: malformed JSON string, neither tag, array, object, number, string or atom, at character offset 10 (before ",]")
[,1]
Parse Error: malformed JSON string, neither tag, array, object, number, string or atom, at character offset 1 (before ",1]")
'{,}'
Parse Error: malformed JSON string, neither tag, array, object, number, string or atom, at character offset 0 (before "'{,}'")
"[]"
Parse Error: JSON text must be an object or array (but found number, string, true, false or null, use allow_nonref to allow this)
" []"
Parse Error: JSON text must be an object or array (but found number, string, true, false or null, use allow_nonref to allow this)
"\n[]"
Parse Error: JSON text must be an object or array (but found number, string, true, false or null, use allow_nonref to allow this)
"# foo\n[]"
Parse Error: JSON text must be an object or array (but found number, string, true, false or null, use allow_nonref to allow this)
"# fo[o\n[]"
Parse Error: JSON text must be an object or array (but found number, string, true, false or null, use allow_nonref to allow this)
"# fo]o\n[]"
Parse Error: JSON text must be an object or array (but found number, string, true, false or null, use allow_nonref to allow this)
"[# fo]o\n]"
Parse Error: JSON text must be an object or array (but found number, string, true, false or null, use allow_nonref to allow this)
""
Parse Error: JSON text must be an object or array (but found number, string, true, false or null, use allow_nonref to allow this)
" "
Parse Error: JSON text must be an object or array (but found number, string, true, false or null, use allow_nonref to allow this)
"\n"
Parse Error: JSON text must be an object or array (but found number, string, true, false or null, use allow_nonref to allow this)
"#,foo\n"
Parse Error: JSON text must be an object or array (but found number, string, true, false or null, use allow_nonref to allow this)
# []o\n

'#\n[#foo\n"#\\n"#\n]'
Parse Error: malformed JSON string, neither tag, array, object, number, string or atom, at character offset 0 (before "'#\\n[#foo\\n"#\\\\n...")
