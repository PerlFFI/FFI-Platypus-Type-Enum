use Test2::V0 -no_srand => 1;
use FFI::Platypus 1.00;
use FFI::Platypus::Type::Enum;

my $ffi = FFI::Platypus->new( api => 1 );

$ffi->load_custom_type('::Enum','enum1',
  'one',
  'two',
  ['four',4],
  'five',
);

is($ffi->cast('enum1', 'enum', 'one'), 0);
is($ffi->cast('enum1', 'enum', 'two'), 1);
is($ffi->cast('enum1', 'enum', 'four'),4);
is($ffi->cast('enum1', 'enum', 'five'),5);

done_testing;


