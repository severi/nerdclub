use 5.0.010;
use Irssi;
use strict;
use vars qw($VERSION %IRSSI);

$VERSION = "0.8.14";
%IRSSI = (
authors     => "Sepa",
contact     => "sepajandro",
name        => "nerdbot",
description => "tekee juttuja",
license     => "GPLv2",
url         => "http://irssi.org",
);

sub funk 
{
	my $range = 5;
	my $rand = int(rand($range));
	my ($server, $data, $nick, $mask, $target) =@_;
	if ($rand == 0){$server->command ("/msg !nerdclub $nick: Welcome to !nerdclub :-)");}
	elsif ($rand == 1){$server->command ("/msg !nerdclub $nick: I've been expecting you!");}
	elsif ($rand == 2){$server->command ("/msg !nerdclub $nick: Welcome to the land of WOLOLOO!");}
	elsif ($rand == 3){$server->command ("/msg !nerdclub $nick: ALL HAIL, KING OF THE LOSERS!");}
	else{$server->command ("/msg !nerdclub $nick: Long time, no ocean.");}
}

Irssi::signal_add_last('message join', 'funk');

