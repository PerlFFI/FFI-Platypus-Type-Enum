package FFI::Platypus::Type::Enum;

use strict;
use warnings;
use constant 1.32 ();
use 5.008001;
use Ref::Util qw( is_plain_arrayref is_plain_hashref is_ref );
use Carp qw( croak );

# ABSTRACT: Custom platypus type for dealing with C enumerated types
# VERSION

=head1 SYNOPSIS

C:

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

Perl with strings:

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

Perl with constants:

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
 

=head1 DESCRIPTION

This type plugin is a helper for making enumerated types.  It makes the most sense
to use this when you have an enumerated type with a small number of possible values.
For a large set of enumerated values or constants, see L<FFI::Platypus::Constant>.

This type plugin has two modes:

=over 4

=item string

In string mode, string representations of the enum values are converted into
the integer enum values when passed into C, and the enums are converted back
into strings when coming from C back into Perl.  You can also pass in the
integer values.

=item constant

In constant mode, constants are defined in the specified package, and with
the optional prefix.  The string representation or integer constants can
be passed into C, but the integer constants are returned from C back into
Perl.

=back

In both modes, if you attempt to pass in a value that isn't one of the possible
enum values, an exception will be thrown.

The enumerated values are specified as a list of strings and array references.
For strings the constant value starts at zero (0) and increases by one for each
possible value.  You can use an array reference to indicate an alternate integer
value to go with your constant.

=head1 OPTIONS

=head2 package

 $ffi->load_custom_type('::Enum', $name, { package => $package }, ... );

This option specifies the Perl package where constants will be defined.
If not specified, then not constants will be generated.  As per the usual
convention, the constants will be the upper case of the value names.

=head2 prefix

 $ffi->load_custom_type('::Enum', $name, { prefix => $prefix }, ... );

This specifies an optional prefix to give each constant.  If not specified,
then no prefix will be used.

=head2 rev

 $ffi->load_custom_type('::Enum', $name, { prefix => 'int' }, ... );
 $ffi->load_custom_type('::Enum', $name, { prefix => 'str' }, ... );

This specifies what should be returned for C functions that return the
enumerated type.  For strings, use C<str>, and for integer constants
use C<int>.

=head2 type

 $ffi->load_custom_type('::Enum', $name, { type => $type }, ... );

This specifies the integer type that should be used for the enumerated
type.  The default is to use C<enum> for types that only have positive
possible values and C<senum> for types that have possible negative values.
(Note that on some platforms these two types may actually be the same).

You can also use other integer types, which is useful if the enum is
only used to define constants, and the values are stored in a type
smaller than the default for C<enum> or C<senum>.  For example:

C:

 enum {
   DEFAULT,
   BETTER,
   BEST = 12
 } foo_enum;
 typedef uint8_t foo_t;

Perl:

 $ffi->load_custom_type('::Enum', 'foo_t',
   { type => 'uint8' },
   'default',
   'better',
   [best => 12],
 );

=head1 SEE ALSO

=over 4

=item L<FFI::Platypus>

=item L<FFI::C>

=back

=cut

our @CARP_NOT = qw( FFI::Platypus );

sub ffi_custom_type_api_1
{
  my %config = defined $_[2] && is_plain_hashref $_[2]
    ? %{ splice(@_, 2, 1) }
    : ();
  my(undef, undef, @values) = @_;

  my $index = 0;
  my %str_lookup;
  my %int_lookup;
  my $prefix = defined $config{prefix} ? $config{prefix} : '';
  $config{rev} ||= 'str';
  ($config{rev} =~ /^(int|str)$/) or croak("rev must be either 'int', or 'str'");

  foreach my $value (@values)
  {
    my $name;
    if(is_plain_arrayref $value)
    {
      ($name,$index) = @$value;
    }
    elsif(!is_ref $value)
    {
      $name = $value;
    }
    else
    {
      croak("not a array ref or scalar: $value");
    }

    if($index < 0)
    {
      $config{type} ||= 'senum';
    }

    if(my $package = $config{package})
    {
      my $full = join '::', $package, $prefix . uc($name);
      constant->import($full, $index);
    }

    $int_lookup{$index} = $index;
    $str_lookup{$name}  = $index++;
  }

  $config{type} ||= 'enum';

  my %type = (
    native_type    => $config{type},
    perl_to_native => sub {
      defined $str_lookup{$_[0]}
        ? $str_lookup{$_[0]}
        : defined $int_lookup{$_[0]}
          ? $int_lookup{$_[0]}
          : croak("illegal enum value $_[0]");
    },
  );

  unless($config{rev} eq 'int')
  {
    my %rev_lookup = reverse %str_lookup;
    $type{native_to_perl} = sub {
      defined $rev_lookup{$_[0]}
        ? $rev_lookup{$_[0]}
        : $_[0];
    }
  }

  \%type;
}

1;
