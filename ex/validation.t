use Mojo::Base -strict;

use Test::More;
use Test::Mojo;

use FindBin '$Bin';
require "$Bin/validation.pl";

my $t = Test::Mojo->new;
$t->ua->max_redirects( 2 );

$t->get_ok('/')
  ->status_is(200)
  ->text_is( h1 => 'Please register' )
  ->element_exists( 'form' );

my $registration= { user => 'joel', pass => 'mypass' };
$t->post_ok( '/' => form => $registration)
  ->status_is(200)
  ->element_exists( 'label.field-with-error' );

$registration= { user => 'marcus', pass => 'ohmypass', pass_again => 'ohmypass' };
$t->post_ok( '/' => form => $registration)
  ->status_is(200)
  ->text_is( h1 => 'Registered as Marcus' );

$t->get_ok('/logout')
  ->status_is(200)
  ->element_exists('form');

done_testing;
