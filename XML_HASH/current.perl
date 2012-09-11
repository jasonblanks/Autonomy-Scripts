#	XML Source check v1.0 
#	Author: Jason Blanks
#
#	This is a simple script to check xml sources for deletions made referencing a hash file.
#	On first use this will initialize the hash file set for all sources defined under the 
#	%sources hash.  To add new sources just follow the same format, same goes for IDOL changes.
#
#


use HTTP::Request::Common qw(POST);
use LWP::UserAgent;
use XML::Simple;
use URI;

#####   GLOBALS   #####
my @records = ();
my @current = ();
my @hash = ();
my @deleted = ();
my @URLs = ("http://192.168.180.94:9001/DREDELETEREF?docs="
			#, "http://10.0.0.1:9001/DREDELETEREF?docs="
			);
my %Sources = ( '\\\\ilmn-www-test\\illumina\\xml\\documentation_list.ilmn' => 'hash_documentation_list.txt',
				'\\\\ilmn-www-test\\illumina\\xml\\literature_list.ilmn' => 'hash_literature_list.ilmn.txt'
				);

#####   FUNCTIONS   #####

sub GetUrls {
	@records = ();
	my $xml = new XML::Simple;
	my $source_xml = $xml->XMLin($location);
	#foreach my $article (@{$source_xml->{SearchItem}}) {
	foreach my $article (@{$source_xml->{SearchItems}->{SearchItem}}) {
	my $a = {'Url' => $article->{Url}};
	push(@records, $a);
	}
}

sub WriteFile {
	open (MYFILE, '>', $hashfile);
	foreach my $e (@records) {
	print MYFILE $e->{Url} . "\n";
	}
	close (MYFILE);
}	

sub BuildCurrentArray {
	@current = ();
	foreach my $e (@records) {
	push (@current, $e->{Url});
	}
	chomp(@current);
}

sub BuildHashArray {
		@hash = ();
		open (MYFILE, '<', $hashfile);
		@hash = <MYFILE>;
		close (MYFILE);
		chomp(@hash);
		}

sub Compare {
	@deleted = ();
	my @added = ();
	my @TempHash = ();
	my $flag = 0;
	chomp(@hash);
	chomp(@current);

	foreach my $key1 ( @hash)
		{
		$flag=0; # set the flage value
			foreach my $key2 ( @current)
				{
				if ($key1 eq $key2)
					{
					$flag=1;
					next;
					}
				}
				# that considered array 1 element doesn't match array2 elements
				if ($flag == 1 ) 
					{
					#print "\nValue '$key1' doesn't exist in \@Array2";
					push(@TempHash, $key1);
					}	
				if ($flag == 0 ) 
					{
					#print "\nValue '$key1' doesn't exist in \@Array2";
					push(@deleted, $key1);
					}	
		}
	foreach my $key3 ( @current)
		{
		$flag=0; # set the flage value
			foreach my $key4 ( @hash)
				{
				if ($key3 eq $key4)
					{
					$flag=1;
					next;
					}
				}
				# that considered array 1 element doesn't match array2 elements
				if ($flag == 0 ) 
					{
					#print "\nValue '$key1' doesn't exist in \@Array2";
					push(@added, $key3);
					}	
		}
	open (MYFILE, '>', $hashfile);
	foreach my $o (@TempHash) {
	print MYFILE $o . "\n";
	}
	foreach my $m (@added) {
	print MYFILE $m . "\n";
	}
	close (MYFILE);
}
sub DeleteURLs {
	$ua = LWP::UserAgent->new;
	foreach my $url (@URLs) {
		foreach my $d (@deleted) {
			my $response = $ua->request(POST $url.$d,);
			#print $response->error_as_HTML unless $response->is_success;
			print $response->as_string;		
			}
	
	}
}
	

#####   MAIN   #####

foreach $key (keys %Sources)
{
  # do whatever you want with $key and $value here ...
  $hashfile = $Sources{$key};
  $location = $key;

		if (-e $hashfile) {
			print "Hash file exists for ".$location.", running checks and updating. \n";
			&GetUrls;
			&BuildCurrentArray;
			&BuildHashArray;
			&Compare;
			&DeleteURLs;
			print "deleted size = ", @deleted. "\n";
			print "TempHash size = ", @TempHash. "\n";
			print "hash size = ", @hash. "\n";
			print "current size = ", @current. "\n";
			}

		else {
			print "First run, creating hash for ".$location.". \n";
			&GetUrls;
			&WriteFile;
			}
}
