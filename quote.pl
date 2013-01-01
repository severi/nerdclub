use 5.0.010;
use Irssi;
use vars qw($VERSION %IRSSI);
# PERL MODULES WE WILL BE USING
use DBI;
use DBD::mysql;


require 'auth1.pl';

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


sub insertQuote{
	$quoteAt = $_[0];
	

	# DATA SOURCE NAME
	$dsn = "dbi:mysql:$database:localhost:3306";

	# PERL DBI CONNECT
	$connect = DBI->connect($dsn, $user, $pw);

	# PREPARE THE QUERY
	$query = "INSERT INTO Quotes(quote) VALUES( '$quoteAt' )";
	$query_handle = $connect->prepare($query);

	# EXECUTE THE QUERY
	$query_handle->execute();
}

sub getQuotes{
	# DATA SOURCE NAME
	$dsn = "dbi:mysql:$database:localhost:3306";

	# PERL DBI CONNECT
	$connect = DBI->connect($dsn, $user, $pw);

	# PREPARE THE QUERY
	$query = "SELECT * FROM Quotes";
	$query_handle = $connect->prepare($query);

	# EXECUTE THE QUERY
	$query_handle->execute();


	# BIND TABLE COLUMNS TO VARIABLES
	$query_handle->bind_columns(undef, \$quote);


	my @quoteArray;
	while($query_handle->fetch()) { 
		push(@quoteArray,$quote);
	}
	return @quoteArray;
}


sub funk {
	my ($server, $data, $nick, $mask, $target) =@_;
	if ($data eq "!q")	#halutaan random quote $data=~/^!q/
	{
		#valitaan seuraavaksi random numer, s.e. suurin mahdollinen on quotejen lkm
		my @quotes = getQuotes();
		my $range = @quotes;
		my $random_number = int(rand($range)); #randomnumber = 0...lkm-1;

		my $quote = $quotes[$random_number];
		$server->command("/msg !nerdclub $quote");
	}
		
	else{
		if (substr($data,0,4)=~/^!add/)
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
}

Irssi::signal_add_last('message public', 'funk');

