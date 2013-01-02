use 5.0.010;
use Irssi;
use vars qw($VERSION %IRSSI);
use DBI;
use DBD::mysql;


require 'auth.pl';

$VERSION = "0.8.14";
%IRSSI = (
authors     => "Sepa",
contact     => "sepajandro",
name        => "nerdbot",
description => "tekee juttuja",
license     => "GPLv2",
url         => "http://irssi.org",
);


($platfrom,$database, $host, $port, $tablename, $user, $pw) = get_auth("quotes");

##################
##	COMMON	##
##################

sub trim($)
{
	my $string = shift;
	$string =~ s/^\s+//;
	$string =~ s/\s+$//;
	return $string;
}

##################
##	QUOTES	##
##################

sub insertQuote{
	$quoteAt = $_[0];
	$dsn = "dbi:mysql:$database:$host:$port";
	$connect = DBI->connect($dsn, $user, $pw);
	$query = "INSERT INTO Quotes(quote) VALUES(?)";
	$query_handle = $connect->prepare($query);
	$query_handle->execute($quoteAt);
}

sub getQuotes{
	$dsn = "dbi:mysql:$database:$host:$port";
	$connect = DBI->connect($dsn, $user, $pw);
	$query = "SELECT * FROM Quotes";
	$query_handle = $connect->prepare($query);
	$query_handle->execute();
	$query_handle->bind_columns(undef, \$quote);
	my @quoteArray;
	while($query_handle->fetch()) { 
		push(@quoteArray,$quote);
	}
	return @quoteArray;
}


###################
##	STATS	 ##
###################


sub addMsg{
	$nick = $_[0];
	$dsn = "dbi:mysql:$database:$host:$port";
	$connect = DBI->connect($dsn, $user, $pw);
	$query = "INSERT INTO Stats (nick,number) VALUES (?,1) ON DUPLICATE KEY UPDATE number=number+1";
	$query_handle = $connect->prepare($query);
	$query_handle->execute($nick);
}

sub getBest(){
	$dsn = "dbi:mysql:$database:$host:$port";
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
	$dsn = "dbi:mysql:$database:$host:$port";
	$connect = DBI->connect($dsn, $user, $pw);
	$query = "SELECT number FROM Stats WHERE nick=?";
	$query_handle = $connect->prepare($query);
	$query_handle->execute($nick);
	$query_handle->bind_columns(undef, \$number);

	while($query_handle->fetch()) { 
		return ($number);
	}
	return 0;
}

sub nick_change 
{
	my ($server, $newnick, $nick, $address) = @_;
	$newnick=trim(substr($newnick,1));
	$dsn = "dbi:mysql:$database:$host:$port";
	$connect = DBI->connect($dsn, $user, $pw);
	$query = "UPDATE Stats SET nick=? WHERE nick=?";
	$query_handle = $connect->prepare($query);
	$query_handle->execute($newnick, $nick);
}

##################
##	WELCOME	##
##################

sub welcome 
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

##################
##	MAIN	##
##################

sub main {
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

	elsif ($data eq "!q")	
	{
		my @quotes = getQuotes();
		my $range = @quotes;
		my $random_number = int(rand($range));
		my $quote = $quotes[$random_number];
		$server->command("/msg !nerdclub $quote");
	}
		
	elsif (substr($data,0,4)=~/^!add/)
	{
		my $part2 = substr($data, 5);
		insertQuote("$part2");	
		$server->command ("/msg !nerdclub Added Quote: $part2\n");
	}
	
	elsif ($data eq "!help")
	{
		$server->command ("/msg $nick Commandlist: !q  = Shows a random quote.     !add <nick> <quote>  = Adds a new quote.  !help  = Shows the commandlist and the explanations");
	}
}



##################
##	IRSSI	##
##################
	
Irssi::signal_add_last('message public', 'main');
Irssi::signal_add_last('event nick', 'nick_change');
Irssi::signal_add_last('message join', 'welcome');

