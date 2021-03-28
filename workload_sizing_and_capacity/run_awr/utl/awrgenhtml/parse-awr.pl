#!/usr/bin/env perl

use strict;
use warnings;
use Data::Dumper;
use IO::File;

my $debug=0;

=head1 Parse AWR

 HTML AWR reports have been converted to asciidoc via pandoc

    pandoc --columns=65000 --eol=lf --ascii -f html -t asciidoc INFILE -o OUTfILE

 Why do this?

 The AWR data is aged out (no baselines) and the only available reports are HTML

 Otherwise and AWR diff report would have been quite useful

 So, get data from the following report sections


 Begin Time
 Elapsed Time 
 DB Time

 Both Elapsed and DB Time are reported in minutes

 Time, Executions and Average times from 

 - Load Profile
 - Top 5 Timed Foreground events
 - CPU stats
 - Memory stats
 - Time Model Statistics
 - Operating System Statistics
 - Operating System Statistics (detail)
 - Foreground Wait Class
 - Top Foreground Wait Events
 - Top Background Wait Events

 Some of the SQL stats
 Top 10 from each of :


 - SQL ordered by Elapsed Time
 - SQL ordered by CPU Time
 - SQL ordered by User I/O Wait Time

 Example:


 ./parse-awr.pl awrrpt*.txt

 Begin Time: 25-Sep-17 08:00:01
 Elapsed Seconds: 39600.6
 DB Seconds: 629137.2
 
 Begin Time: 06-Nov-17 08:00:01
 Elapsed Seconds: 32400.6
 DB Seconds: 523926

 Begin Time: 07-Nov-17 02:00:02
 Elapsed Seconds: 3599.4
 DB Seconds: 91552.8

 Begin Time: 12-Dec-17 09:00:01
 Elapsed Seconds: 10800
 DB Seconds: 162718.8

 Begin Time: 12-Dec-17 12:00:01
 Elapsed Seconds: 21600.6
 DB Seconds: 282987


 >  ls -l *.csv
 -rwxr-xr-x 1 oracle dba  4363 Jun 19 15:28 background-wait-events.csv
 -rwxr-xr-x 1 oracle dba  3136 Jun 19 15:28 foreground-wait-class.csv
 -rwxr-xr-x 1 oracle dba  4387 Jun 19 15:28 foreground-wait-events.csv
 -rwxr-xr-x 1 oracle dba   414 Jun 19 15:28 host-cpu.csv
 -rwxr-xr-x 1 oracle dba   343 Jun 19 15:28 instance-cpu.csv
 -rwxr-xr-x 1 oracle dba  5035 Jun 19 15:28 load-profile.csv
 -rwxr-xr-x 1 oracle dba  1474 Jun 19 15:28 memory-stats.csv
 -rwxr-xr-x 1 oracle dba 11000 Jun 19 15:28 os-stats-detail.csv
 -rwxr-xr-x 1 oracle dba  6377 Jun 19 15:28 os-stats.csv
 -rwxr-xr-x 1 oracle dba  9361 Jun 19 15:28 sql-by-cpu.csv
 -rwxr-xr-x 1 oracle dba  9124 Jun 19 15:28 sql-by-elapsed.csv
 -rwxr-xr-x 1 oracle dba  9229 Jun 19 15:28 sql-by-io.csv
 -rwxr-xr-x 1 oracle dba  5729 Jun 19 15:28 time-model-stats.csv
 -rwxr-xr-x 1 oracle dba  2180 Jun 19 15:28 top-foreground-events.csv
 

=cut

my $headerSearch=1;  # reset only after 'DB Time' is found

# elapsed time and db time will be converted to seconds
my ($beginTime,$elapsedTime,$dbTime);

die "Please specify some files!\n" unless $ARGV[0];

foreach my $file (@ARGV) {
	# validate that at the least these are files that can be read
	pdebug( "checking file $file");
	unless ( -r $file ) {
		die "could not read $file - $!\n";
	}
}

my %rptData=();
my %rptFormat = ();

#print Dumper(\@ARGV);
#exit;

foreach my $file (@ARGV) {

	my $fh = IO::File->new;

	pdebug("Opening file: $file");
	$fh->open($file,'<') or die "Could not read $file - $!\n";
	pdebug("Opened file: $file");

	while (<$fh>) {
	
		chomp;
		my $line=$_;
		$line =~ s/[^[:ascii:]]//g;

		# look first for the report info

		if ($headerSearch) {

			# asciidoc data lines are delimited with '|' and always begin with the delimiter
			my @a=split(/\|/, $line);
			shift @a;

			# remove all spaces from end of elements
			$_ =~ s/\s+$//g for @a;

			pdebug("Searching for times in file $file");
			print Dumper(\@a) if $debug;

			if ( defined($a[0])) {
				if ($a[0] =~ /Begin Snap:/) { 
					# appears as NNN,NNN.N (mins)
					$beginTime = $a[2]; 
					pdebug("Found Begin Time: $beginTime");
				}
				elsif ($a[0] =~ /Elapsed:/) { 
					# appears as NNN,NNN.N (mins)
					$elapsedTime = (split(/\s+/,$a[2]))[0];
					$elapsedTime =~ s/,//go;
					$elapsedTime *= 60;
				}
				elsif ($a[0] =~ /DB Time:/) { 
					pdebug("\$a[2]: $a[2]");
					# appears as NNN,NNN.N (mins)
					$dbTime = (split(/\s+/,$a[2]))[0];
					$dbTime =~ s/,//go;
					$dbTime *= 60;
	
					$headerSearch=0;
				}

			}

		}

		last unless $headerSearch;
	}

	# first non-blank field that indicates start of heading per section
	# array values [first column name, column position, number of metrics to keep,output file]

	%rptFormat = (
		'Load Profile'										=> ['Per Second',1,99999,'load-profile'],
		#'Top 5 Timed Foreground Events'				=> ['Event',0,99999,'top-foreground-events'],
		'Top 10 Foreground Events by Total Wait Time'		
																=> ['Event',0,99999,'top-10-foreground-events'],
		'Host CPU'											=> ['Load Average Begin',0,99999,'host-cpu'],
		'Instance CPU'										=> ['%Total CPU',0,99999,'instance-cpu'],
		'Memory Statistics'								=> ['Begin',1,99999,'memory-stats'],
		'Time Model Statistics'							=> ['Statistic Name',0,99999,'time-model-stats'],
		'Operating System Statistics'					=> ['Statistic',0,99999,'os-stats'],
		'Operating System Statistics - Detail'		=> ['Snap Time',0,99999,'os-stats-detail'],
		'Foreground Wait Class'							=> ['Wait Class',0,99999,'foreground-wait-class'],
		'Foreground Wait Events'						=> ['Event',0,10,'foreground-wait-events'],
		'Background Wait Events'						=> ['Event',0,10,'background-wait-events'],
		'SQL ordered by Elapsed Time'					=> ['Elapsed Time (s)',0,99999,'sql-by-elapsed'],
		'SQL ordered by CPU Time'						=> ['CPU Time (s)',0,99999,'sql-by-cpu'],
		'SQL ordered by User I/O Wait Time'			=> ['User I/O Time (s)',0,99999,'sql-by-io'],
	);

	my @headers=keys %rptFormat;
	$headerSearch=1;
	my $currHeader='';
	my $dataSearch=0;
	my $dataFound=0;
	my $dataEnd=0;
	my $endDataMarker = '=' x 10;
	my $data='';
	my $searchColumn;
	my $searchColumnNum;

=head1 %rptData()

	date => {
		beginTime => data,
		elapsedSeconds => data,
		dbSeconds => data,
		heading => {
			columns => [],
			data [
				[]
			]
		}
		...
	}
		

=cut


	$rptData{$beginTime}->{beginTime} = $beginTime;
	$rptData{$beginTime}->{elapsedSeconds} = $elapsedTime;
	$rptData{$beginTime}->{dbSeconds} = $dbTime;

	my $metricsCount=0;
	my $maxMetricsCount=0;

	# now process the rest of the file
	while (<$fh>) {
	
		chomp;
		my $line = $_;
		next unless $line;
		# trim trailing space if any
		$line =~ s/\s+$//g;

		# convert link:#b4j3qz75jr2k6[b4j3qz75jr2k6] to just the SQL_ID
		# |1,971.82 |1 |1,971.82 |1.21 |99.97 |0.00 |link:#9zt679fsw5an6[9zt679fsw5an6] |cli@message_group_count.php |SELECT count(*) FROM ( SELECT...
		# fix this regex another time
		#$line =~ s/^(.++)\|link:#.+\[(.++)\](.*)$/$1$2$3/;
		# these 2 simple ones will do it for now
		$line =~ s/link:#.+\[//go;
		$line =~ s/\]//go;

		if ($headerSearch) {
			#print "line: $line\n";
			# quotemeta prefixes special characters with a backslash
			pdebug("looking for headings");
			#
			# remove unpredictable info from Host CPU heading
			if ($line =~ /^Host CPU /) { $line = 'Host CPU' }

			my $testLine = quotemeta($line);

			if ( grep(/^$testLine/,@headers)) {
				pdebug("found header: |$line|");
				$currHeader = $line;
				$headerSearch=0;
				$dataSearch=1;
				$searchColumn = $rptFormat{$line}[0];
				$searchColumnNum = $rptFormat{$line}[1];
				$maxMetricsCount = $rptFormat{$line}[2];
				$metricsCount = 0;
			}
		} elsif ( $dataSearch ) {

			# look for the header line in the data
			my @a=split(/\|/,$line);
			shift @a;

			# remove all spaces from end of elements
			$_ =~ s/\s+$//g for @a;

			if (! $dataFound ) {

				#my $column
				next unless $a[ $searchColumnNum ];

				my $currColumn = $a[ $searchColumnNum ];
				$currColumn =~ s/\s+$//o;

				pdebug("current column: |$currColumn|");
			 	pdebug("Searching for |$searchColumn|");

				if ($currColumn eq $searchColumn ) {

					pdebug("Found Column Header: $searchColumn");

					pdebug(join(" : ", @a));

					$rptData{$beginTime}->{$currHeader}{columns}=\@a;

					$dataFound=1;
				}
			} else { # reading data for heading
				pdebug("reading data");
				if ( $a[0] =~ /$endDataMarker/ ) {
						$dataFound=0;
						$headerSearch=1;
						$dataSearch=0;
						#$dataEnd=1;
				} else {

					if ($metricsCount++ >= $maxMetricsCount) {
						next;
					}

					push @{$rptData{$beginTime}->{$currHeader}{data}},\@a;

					pdebug(join(" : ", @a));

				}

			}
		
		} elsif ( $dataSearch and $headerSearch ) {
			die "\$dataSearch and \$headerSearch should not happen\n";
		} elsif ( ! $dataSearch and ! $headerSearch ) {
			die "! \$dataSearch and ! \$headerSearch should not happen\n";
		} else {
			die "Unknown condition in header search\n";
		}

	}

	$headerSearch = 1;


print qq{
     Begin Time: $beginTime
Elapsed Seconds: $elapsedTime
     DB Seconds: $dbTime

};

}


print Dumper(\%rptData) if $debug;


=head1 %rptData()

	date => {
		beginTime => data,
		elapsedSeconds => data,
		dbSeconds => data,
		heading => {
			columns => [],
			data [
				[]
			]
		}
		...
	}
		

=cut

# now output data

my $delimiter=',';
my $fileExtension='csv';

# initialize output files
my $fh;

foreach my $heading ( keys %rptFormat ) {
	my $fileName = $rptFormat{$heading}->[3] . '.' . $fileExtension;
	print "File: $fileName\n" if $debug;
	$fh = IO::File->new($fileName,'>');
	push @{$rptFormat{$heading}}, $fh;
}

print Dumper(\%rptFormat) if $debug;

#exit;

my $printColumnNames=1;

foreach my $beginTime ( keys %rptData ) {

	pdebug ("BeginTime: $beginTime");

	my ($dbSeconds, $elapsedSeconds) = (
		$rptData{$beginTime}->{dbSeconds},
		$rptData{$beginTime}->{elapsedSeconds},
	);

	# print column nanes only once
	
	foreach my $heading ( keys %rptFormat ) {

		pdebug ("   Heading: $heading");

		my @columns=();
		eval {
			@columns=@{$rptData{$beginTime}->{$heading}{columns}};
			unshift @columns, 'BeginTime','ElapsedSeconds','DBSeconds';
		};
		

		# if there is no data for this $rptData{time}->{$heading}, just skip to the next one
		next if $@; 

		# remove the delimiter from the data as needed
		$_ =~ s/$delimiter//g for @columns;

		print { $rptFormat{$heading}->[4] } join("$delimiter",@columns),"\n" if $printColumnNames;

		foreach my $ary ( @{$rptData{$beginTime}->{$heading}{data}} ) {
			#my @data=@{$rptData{$beginTime}->{$heading}{data}[$el]};
			my @data=@{$ary};
			unshift @data, $beginTime, $elapsedSeconds, $dbSeconds;
			# remove non-ascii from output data - pandoc has added 0xC2 and likely others
			# also remove the delimiter from data, probably a comma
			$_ =~ s/[^[:ascii:]]//g for @data;
			$_ =~ s/$delimiter//g for @data;
			print { $rptFormat{$heading}->[4] } join("$delimiter",@data),"\n";
		}

	}

	$printColumnNames=0;
}


# send a string
sub pdebug {

	return unless $debug;
	my $line = shift;

	print '=' x 80 . "\n";
	print "$line\n";
	print '=' x 80 . "\n";

	return;

}

