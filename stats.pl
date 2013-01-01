
use Irssi;
use vars qw($VERSION %IRSSI);
# PERL MODULES WE WILL BE USING
use DBI;
use DBD::mysql;


require 'auth2.pl';


$VERSION = "0.8.14";
%IRSSI = (
authors     => "Sepa",
contact     => "sepajandro",
name        => "nerdbot",
description => "tekee juttuja",
license     => "GPLv2",
url         => "http://irssi.org",
);


($platfrom,$database, $host, $port, $tablename, $user, $pw) = get_auth("Stats");

sub addMsg{
	$nick = $_[0];

	# DATA SOURCE NAME
	$dsn = "dbi:mysql:$database:localhost:3306";

	# PERL DBI CONNECT
	$connect = DBI->connect($dsn, $user, $pw);

	$query = "INSERT INTO Stats (nick,number) VALUES ('$nick',1) ON DUPLICATE KEY UPDATE number=number+1";
	$query_handle = $connect->prepare($query);

	# EXECUTE THE QUERY
	$query_handle->execute();
}

sub trim($)
{
	my $string = shift;
	$string =~ s/^\s+//;
	$string =~ s/\s+$//;
	return $string;
}


sub getBest(){
	$dsn = "dbi:mysql:$database:localhost:3306";
	$connect = DBI->connect($dsn, $user, $pw);
	$query = "SELECT nick, number FROM Stats WHERE number=(SELECT MAX(number) FROM Stats)";
	$query_handle = $connect->prepare($query);
	$query_handle->execute();
	$query_handle->bind_columns(undef, \$nick,\$number);

	while($query_handle->fetch()) { 
		return ($nick,$number);
	}
	return ("no-one","0");
}


sub getNumber{
	my $nick = $_[0];

	$dsn = "dbi:mysql:$database:localhost:3306";
	$connect = DBI->connect($dsn, $user, $pw);
	$query = "SELECT number FROM Stats WHERE nick='$nick'";
	$query_handle = $connect->prepare($query);
	$query_handle->execute();
	$query_handle->bind_columns(undef, \$number);

	while($query_handle->fetch()) { 
		return ($number);
	}
	return 0;
}


sub funk 
{
	my ($server, $data, $nick, $mask, $target) =@_;
	addMsg($nick);
	if ($data eq "!stats")
	{
		my ($name, $best) = getBest();
		$server->command ("/msg !nerdclub The most active nerd is $name with $best posts.")
	}
	elsif (substr($data,0,6)=~/^!stats/)
	{
		my $name = trim(substr($data,7));
		my $lkm = getNumber($name);
		$server->command ("/msg !nerdclub $name has posted $lkm posts.")
	}
}

sub nick_change 
{
	my ($server, $newnick, $nick, $address) = @_;
	$newnick=trim(substr($newnick,1));

	$dsn = "dbi:mysql:$database:localhost:3306";
	$connect = DBI->connect($dsn, $user, $pw);
	$query = "UPDATE Stats SET nick='$newnick' WHERE nick='$nick'";
	$query_handle = $connect->prepare($query);
	$query_handle->execute();
}

	
Irssi::signal_add_last('message public', 'funk');
Irssi::signal_add_last('event nick', 'nick_change');


