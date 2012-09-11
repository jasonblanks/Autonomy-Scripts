use HTTP::Request::Common qw(POST);
use LWP::UserAgent;
use XML::Simple;
use URI;
use Data::Dumper qw(Dumper);

my $url = URI->new('http://10.12.32.124:9000/a=list&print=Fields&PrintFields=DREReference&maxresults=999999');
#my $url = URI->new('http://10.12.32.124:9000/a=list');
#http://10.12.32.124:9000/a=list&print=Fields&PrintFields=DREReference&maxresults=999999


#$url->query_form(
#    'print' => 'fields',
#	'PrintFields' => 'DREReference',
#	'maxresults' => '999999'
#    );

my $response = LWP::UserAgent->new->get($url);
die "Error: ", $response->status_line unless $response->is_success;




	#@records = ();
	my $xml = new XML::Simple;
	my $source_xml = $xml->XMLin($response->content);

	#foreach my $article (@{$source_xml->{SearchItem}}) {
	foreach my $article (@{$source_xml->{"autn:hit"}->{"autn:content"}}) {
	#my $a = {'DREREFERENCE' => $article->{DREREFERENCE}};
	print Dumper($article) . "\n";
	#print Dumper($a) . "\n";
	#my $a = {'DREREFERENCE' => $article->{DREREFERENCE}};
	#print Dumper($a);
	}
	#print Dumper($article);
	#->{'autn:hit'}->{'autn:content'}->{DOCUMENT}->{DREREFERENCE}
	#my $a = {'Url' => $article->{DREREFERENCE}};
	#push(@records, $a);
	#}
	#print @records;