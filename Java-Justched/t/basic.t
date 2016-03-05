use warnings;
use strict;
use Test::More tests => 2;

require_ok('Java::Justched');
can_ok( 'Java::Justched',
    (qw(gen_pkg get_remote_jvm get_local_jvm check_arch send_notification)) );
