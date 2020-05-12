# FFI::Platypus::Type::Enum [![Build Status](https://travis-ci.org/Perl5-FFI/FFI-Platypus-Type-Enum.svg)](http://travis-ci.org/Perl5-FFI/FFI-Platypus-Type-Enum)

Custom platypus type for dealing with C enumerated types

# SYNOPSIS

C:

```
enum {
  DEFAULT,
  BETTER,
  BEST = 12
} foo_t;

foo_t
f(foo_t arg)
{
  return foo_t;
}
```

Perl with strings:

```perl
use FFI::Platypus 1.00;
my $ffi = FFI::Platypus->new( api => 1 );

$ffi->load_custom_type('::Enum', 'foo_t',
  'default',
  'better',
  ['best' => 12],
);

$ffi->attach( f => ['foo_t'] => 'foo_t' );

f("default") eq 'default';  # true
f("default") eq 'better';   # false

print f("default"), "\n";   # default
print f("better"),  "\n";   # better
print f("best"),    "\n";   # best
```

Perl with constants:

```perl
use FFI::Platypus 1.00;
my $ffi = FFI::Platypus->new( api => 1 );

$ffi->load_custom_type('::Enum', 'foo_t', 
  { ret => 'int', package => 'Foo', prefix => 'FOO_' },
  'default',
  'better',
  ['best' => 12],
);

$ffi->attach( f => ['foo_t'] => 'foo_t' );

f(Foo::FOO_DEFAULT) == Foo::FOO_DEFAULT;   # true
f(Foo::FOO_DEFAULT) == Foo::FOO_BETTER;    # false
```

# DESCRIPTION

This type plugin is a helper for making enumerated types.  It makes the most sense
to use this when you have an enumerated type with a small number of possible values.
For a large set of enumerated values or constants, see [FFI::Platypus::Constant](https://metacpan.org/pod/FFI::Platypus::Constant).

This type plugin has two modes:

- string

    In string mode, string representations of the enum values are converted into
    the integer enum values when passed into C, and the enums are converted back
    into strings when coming from C back into Perl.  You can also pass in the
    integer values.

- constant

    In constant mode, constants are defined in the specified package, and with
    the optional prefix.  The string representation or integer constants can
    be passed into C, but the integer constants are returned from C back into
    Perl.

In both modes, if you attempt to pass in a value that isn't one of the possible
enum values, an exception will be thrown.

The enumerated values are specified as a list of strings and array references.
For strings the constant value starts at zero (0) and increases by one for each
possible value.  You can use an array reference to indicate an alternate integer
value to go with your constant.

# OPTIONS

## package

```perl
$ffi->load_custom_type('::Enum', $name, { package => $package }, ... );
```

This option specifies the Perl package where constants will be defined.
If not specified, then not constants will be generated.  As per the usual
convention, the constants will be the upper case of the value names.

## prefix

```perl
$ffi->load_custom_type('::Enum', $name, { prefix => $prefix }, ... );
```

This specifies an optional prefix to give each constant.  If not specified,
then no prefix will be used.

## rev

```perl
$ffi->load_custom_type('::Enum', $name, { prefix => 'int' }, ... );
$ffi->load_custom_type('::Enum', $name, { prefix => 'str' }, ... );
```

This specifies what should be returned for C functions that return the
enumerated type.  For strings, use `str`, and for integer constants
use `int`.

## type

```perl
$ffi->load_custom_type('::Enum', $name, { type => $type }, ... );
```

This specifies the integer type that should be used for the enumerated
type.  The default is to use `enum` for types that only have positive
possible values and `senum` for types that have possible negative values.
(Note that on some platforms these two types may actually be the same).

You can also use other integer types, which is useful if the enum is
only used to define constants, and the values are stored in a type
smaller than the default for `enum` or `senum`.  For example:

C:

```
enum {
  DEFAULT,
  BETTER,
  BEST = 12
} foo_enum;
typedef uint8_t foo_t;
```

Perl:

```perl
$ffi->load_custom_type('::Enum', 'foo_t',
  { type => 'uint8' },
  'default',
  'better',
  [best => 12],
);
```

# SEE ALSO

- [FFI::Platypus](https://metacpan.org/pod/FFI::Platypus)
- [FFI::C](https://metacpan.org/pod/FFI::C)

# AUTHOR

Graham Ollis <plicease@cpan.org>

# COPYRIGHT AND LICENSE

This software is copyright (c) 2020 by Graham Ollis.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.
