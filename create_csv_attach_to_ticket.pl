#!/usr/bin/perl
#######################################create_csv_attach_to_ticket.pl########################################
## 
## Author    : smurcio
## Date      : 07/19/2016
## Dependencies  : N/A
## Inputs    : Name prefix to save CSV file as "filename", string of data to process in CSV format "string"
## Description  : Creates a CSV file with provided comma-separated string
##
#######################################create_csv_attach_to_ticket.pl########################################



use strict;
#use warnings;
use File::Basename;
use Getopt::Long qw(GetOptions);
use Text::CSV_XS;
use Data::Dumper;
use File::Temp qw/ tempfile tempdir /;


my $usage = "Usage: $0 --ticket 123 --filename \"awesome_file\" --username \"ipautomata\" --password \"asdfa345ra\"--string \"String in CSV format\"\n";
if (!@ARGV) {
    print $usage;
    exit 1;
}


my %opts = (
  'ticket' => undef,
  'filename' => undef,
  'username' => undef,
  'password' => undef,
  'string' => undef
);
GetOptions(\%opts,
  'ticket=s',
  'filename=s',
  'username=s',
  'password=s',
  'string=s',
) or die $usage;


#name file to store data (from command line), print to file
my ($fh, $filename);
my $template = "$opts{'filename'}_XXXX";
my $dir = tempdir();

($fh, $filename) = tempfile();
($fh, $filename) = tempfile( $template, SUFFIX => ".csv", DIR => $dir);
binmode( $fh, ":utf8" );

open($fh, '>', "$filename") or die "Internal Error: Could not open file '$filename' $!";
print $fh $opts{'string'};
close($fh);

#attach created csv file to ticket via API
system "curl -X POST -u $opts{'username'}:$opts{'password'} -H \"Content-Type: multipart/form-data\" -F \"filedata=\@$filename\" https://api-ipcenter.ipsoft.com/IPradar/v2/ticket/$opts{'ticket'}/attach/";
