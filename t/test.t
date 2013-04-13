#!/usr/bin/perl

use strict;
use warnings;

use Test::More;

use lib 'lib';

use Flux::Storage::Memory;
use Flux::Format::JSON;

my $storage = Flux::Storage::Memory->new();

my $format = Flux::Format::JSON->new;
my $formatted_storage = $format->wrap($storage);
$formatted_storage->write({ abc => "def" });
$formatted_storage->write("ghi");
$formatted_storage->commit;

is_deeply $storage->data, [
    qq[{"abc":"def"}\n],
    qq["ghi"\n],
];

my $in = $formatted_storage->in('c1');
is_deeply(scalar($in->read), { abc => 'def' }, 'data deserialized correctly');
is_deeply(scalar($in->read), 'ghi', 'simple strings can be stored too');
$in->commit;
undef $in;

$in = $formatted_storage->in('c1');
is($in->read, undef, 'commit worked, nothing to read');

done_testing;
