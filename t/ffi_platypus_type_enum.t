use Test2::V0 -no_srand => 1;
use FFI::Platypus 1.00;
use FFI::Platypus::Type::Enum;

subtest 'default positive enum' => sub {
  my $ffi = FFI::Platypus->new( api => 1 );

  $ffi->load_custom_type('::Enum','enum1',
    'one',
    'two',
    ['four',4],
    'five',
  );

  is($ffi->sizeof('enum1'), $ffi->sizeof('enum'));

  is($ffi->cast('enum1', 'enum', 'one'), 0);
  is($ffi->cast('enum1', 'enum', 0), 0);
  is($ffi->cast('enum1', 'enum', 'two'), 1);
  is(dies { $ffi->cast('enum1', 'enum', 'three') }, match qr/illegal enum value three/);
  is(dies { $ffi->cast('enum1', 'enum', 3) }, match qr/illegal enum value 3/);
  is($ffi->cast('enum1', 'enum', 'four'),4);
  is($ffi->cast('enum1', 'enum', 'five'),5);

  is($ffi->cast('enum', 'enum1', 0), 'one');
  is($ffi->cast('enum', 'enum1', 1), 'two');
  is($ffi->cast('enum', 'enum1', 2), 2);
  is($ffi->cast('enum', 'enum1', 3), 3);
  is($ffi->cast('enum', 'enum1', 5), 'five');
};

subtest 'maps' => sub {
  my $ffi = FFI::Platypus->new( api => 1 );

  my @maps;

  $ffi->load_custom_type('::Enum','enum1', { maps => \@maps },
    'one',
    'two',
    ['four',4],
    'five',
    ['repeat', 4],
  );

  is(\@maps, [
    { one => 0,   two => 1,   four => 4,   five => 5,  repeat => 4 },
    { 0 => 'one', 1 => 'two', 4 => 'four', 5 => 'five' },
  ]);

};

subtest 'default positive uint8' => sub {
  my $ffi = FFI::Platypus->new( api => 1 );

  $ffi->load_custom_type('::Enum','enum1', { type => 'uint8' },
    'one',
    'two',
    ['four',4],
    'five',
  );

  is($ffi->sizeof('enum1'), 1);

  is($ffi->cast('enum1', 'enum', 'one'), 0);
  is($ffi->cast('enum1', 'enum', 0), 0);
  is($ffi->cast('enum1', 'enum', 'two'), 1);
  is(dies { $ffi->cast('enum1', 'enum', 'three') }, match qr/illegal enum value three/);
  is(dies { $ffi->cast('enum1', 'enum', 3) }, match qr/illegal enum value 3/);
  is($ffi->cast('enum1', 'enum', 'four'),4);
  is($ffi->cast('enum1', 'enum', 'five'),5);

  is($ffi->cast('enum', 'enum1', 0), 'one');
  is($ffi->cast('enum', 'enum1', 1), 'two');
  is($ffi->cast('enum', 'enum1', 2), 2);
  is($ffi->cast('enum', 'enum1', 3), 3);
  is($ffi->cast('enum', 'enum1', 5), 'five');
};

subtest 'default negative enum' => sub {
  my $ffi = FFI::Platypus->new( api => 1 );

  $ffi->load_custom_type('::Enum','enum1',
    'one',
    'two',
    ['four',4],
    'five',
    ['neg',-1],
  );

  is($ffi->sizeof('enum1'), $ffi->sizeof('senum'));

  is($ffi->cast('enum1', 'senum', 'one'), 0);
  is($ffi->cast('enum1', 'senum', 0), 0);
  is($ffi->cast('enum1', 'senum', 'two'), 1);
  is(dies { $ffi->cast('enum1', 'senum', 'three') }, match qr/illegal enum value three/);
  is(dies { $ffi->cast('enum1', 'senum', 3) }, match qr/illegal enum value 3/);
  is($ffi->cast('enum1', 'senum', 'four'),4);
  is($ffi->cast('enum1', 'senum', 'five'),5);
  is($ffi->cast('enum1', 'senum', 'neg'), -1);

  is($ffi->cast('senum', 'enum1', 0), 'one');
  is($ffi->cast('senum', 'enum1', 1), 'two');
  is($ffi->cast('senum', 'enum1', 2), 2);
  is($ffi->cast('senum', 'enum1', 3), 3);
  is($ffi->cast('senum', 'enum1', 5), 'five');
  is($ffi->cast('senum', 'enum1', -1),'neg');
};

subtest 'int return negative enum' => sub {
  my $ffi = FFI::Platypus->new( api => 1 );

  $ffi->load_custom_type('::Enum','enum1', { rev => 'int' },
    'one',
    'two',
    ['four',4],
    'five',
    ['neg',-1],
  );

  is($ffi->cast('enum1', 'senum', 'one'), 0);
  is($ffi->cast('enum1', 'senum', 0), 0);
  is($ffi->cast('enum1', 'senum', 'two'), 1);
  is(dies { $ffi->cast('enum1', 'senum', 'three') }, match qr/illegal enum value three/);
  is(dies { $ffi->cast('enum1', 'senum', 3) }, match qr/illegal enum value 3/);
  is($ffi->cast('enum1', 'senum', 'four'),4);
  is($ffi->cast('enum1', 'senum', 'five'),5);
  is($ffi->cast('enum1', 'senum', 'neg'), -1);

  is($ffi->cast('senum', 'enum1', 0), 0);
  is($ffi->cast('senum', 'enum1', 1), 1);
  is($ffi->cast('senum', 'enum1', 2), 2);
  is($ffi->cast('senum', 'enum1', 3), 3);
  is($ffi->cast('senum', 'enum1', 5), 5);
  is($ffi->cast('senum', 'enum1', -1),-1);
};

subtest 'make constants' => sub {
  my $ffi = FFI::Platypus->new( api => 1 );

  $ffi->load_custom_type('::Enum', 'enum1', { package => 'Foo1' },
    'one',
    'two',
  );

  is(Foo1::ONE(), 0);
  is(Foo1::TWO(), 1);
};

subtest 'make constants with prefix' => sub {
  my $ffi = FFI::Platypus->new( api => 1 );

  $ffi->load_custom_type('::Enum', 'enum1', { package => 'Foo2', prefix => 'FOO_' },
    'one',
    'two',
  );

  is(Foo2::FOO_ONE(), 0);
  is(Foo2::FOO_TWO(), 1);
};

subtest 'define errors' => sub {
  my $ffi = FFI::Platypus->new( api => 1 );

  is(
    dies { $ffi->load_custom_type('::Enum','enum1', { rev => 'foo' }) },
    match qr/rev must be either 'int', or 'str'/,
  );

  is(
    dies { $ffi->load_custom_type('::Enum','enum1', sub {}) },
    match qr/not a array ref or scalar: CODE/,
  );

  is(
    dies { $ffi->load_custom_type('::Enum','enum1', 'one','one') },
    match qr/one declared twice/,
  );
};

done_testing;


