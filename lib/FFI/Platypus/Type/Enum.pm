package FFI::Platypus::Type::Enum;

use strict;
use warnings;
use constant 1.32 ();
use 5.008001;
use Ref::Util qw( is_plain_arrayref is_plain_hashref is_ref );
use Carp qw( croak );

# ABSTRACT: Custom platypus type for dealing with C enumerated types
# VERSION

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
