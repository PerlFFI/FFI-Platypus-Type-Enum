# FFI::Platypus::Type::Enum [![Build Status](https://travis-ci.org/PerlFFI/FFI-Platypus-Type-Enum.svg)](http://travis-ci.org/PerlFFI/FFI-Platypus-Type-Enum)

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
  { rev => 'int', package => 'Foo', prefix => 'FOO_' },
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

# OPTIONS

The general form of the custom type load is:

```
$ffi->load_custom_type('::Enum', $name, \%options, @values);
$ffi->load_custom_type('::Enum', $name, @values);
```

The enumerated values are specified as a list of strings and array references.

- string

    ```
    $ffi->load_custom_type('::Enum', $name, $string1, $string2, ... );
    ```

    For strings the constant value starts at zero (0) and increases by one for each
    possible value.

- array reference

    ```
    $ffi->load_custom_type('::Enum', $name, [ $value_name, $value, %options ]);
    $ffi->load_custom_type('::Enum', $name, [ $value_name, %options ]);
    ```

    You can use an array reference to include an explicit integer value, rather
    than using the implicit incremented value.  You can also use the array
    reference for value options.  If the value isn't included (that is if
    there are an odd number of values in the array reference), then the
    implicit incremented value will be used.

    Value options:

    - alias

        ```perl
        $ffi->load_custom_type('::Enum, $name, [ $value_name, $value, alias => \@aliases ]);
        $ffi->load_custom_type('::Enum, $name, [ $value_name, alias => \@aliases ]);
        ```

        The `alias` option lets you specify value aliases.  For example, suppose you have
        an enum definition like:

        ```
        enum {
          FOO,
          BAR,
          BAZ=BAR,
          ABC,
          XYZ
        } foo_t;
        ```

        The Perl definition would be:

        ```perl
        $ffi->load_custom_type('::Enum', 'foo_t',
          'foo',
          ['bar', alias => ['baz']],
          'abc',
          'xyz',
        );
        ```

Type options may be passed in as a hash reference after the type name.

Type options:

- maps

    ```perl
    my @maps;
    $ffi->load_custom_type('::Enum', $name, { maps => \@maps }, ... );
    my($str,$int,$type) = @maps;
    ```

    If set to an empty array reference, this will be filled with the string, integer
    and native type for the enum.

- package

    ```perl
    $ffi->load_custom_type('::Enum', $name, { package => $package }, ... );
    ```

    This option specifies the Perl package where constants will be defined.
    If not specified, then not constants will be generated.  As per the usual
    convention, the constants will be the upper case of the value names.

- prefix

    ```perl
    $ffi->load_custom_type('::Enum', $name, { prefix => $prefix }, ... );
    ```

    This specifies an optional prefix to give each constant.  If not specified,
    then no prefix will be used.

- rev

    ```perl
    $ffi->load_custom_type('::Enum', $name, { rev => 'int' }, ... );
    $ffi->load_custom_type('::Enum', $name, { rev => 'str' }, ... );
    ```

    This specifies what should be returned for C functions that return the
    enumerated type.  For strings, use `str`, and for integer constants
    use `int`.

    (`rev` is short for "reverse")

- type

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

    ```perl
    enum {
      DEFAULT,
      BETTER,
      BEST = 12
    } foo_enum;
    typedef uint8_t foo_t;

    /*
     * you are expected to use the constants from foo_enum,
     * but the signature actually uses a uint8_t
     */
    void f(foo_t);
    ```

    Perl:

    ```perl
    $ffi->load_custom_type('::Enum', 'foo_t',
      { type => 'uint8' },
      'default',
      'better',
      [best => 12],
    );

    $ffi->attach( f => [ 'foo_t' ] => 'void' );
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
