#!/usr/bin/perl

use strict;
use warnings;
use DBI;
use Data::Dumper;

my (@cdhit_id, @strain, @start, %annot);
while (<>) {
    chomp;
    my @fields = split /\t/, $_;
    push @cdhit_id, $fields[0];
}


my $dbh = DBI->connect("dbi:Pg:dbname=bb3-dev;host=Borreliabase.org","","") or die "Couldn't connect to database: ", DBI->errstr;

my $sth = $dbh->prepare("select v.cdhit_id, v.locus, v.strain, v.start, v.stop, a.anno_text from vorf3 as v full join fam_annot as a on v.cdhit_id = a.cdhit_id where v.cdhit_id = ? and v.group_id = 1 limit 1 ");


my $sth1 = $dbh->prepare("(select locus, start, stop ,(case when strand = 't' then 1 else -1 end) as strand, strain, cdhit_id from vorf3 where group_id = 1 and strain = ? and start >= ? order by start asc limit 5) union (select locus, start, stop, (case when strand = 't' then 1 else -1 end) as strand, strain, cdhit_id from vorf3 where group_id = 1 and strain = ? and start < ? order by start desc limit 5) order by start asc");

foreach my $i (0 .. $#cdhit_id) {
    $sth->execute($cdhit_id[$i] );
    while (my @data = $sth->fetchrow()){
#	push @strain, $data[2];
#	push @start, $data[3];
      	print join "\t", $data[0],$data[1],$data[2],$data[3],$data[4],($data[5] ? $data[5] : "N/A");
	print "\n";
#	push @annot, ($data[5] ? $data[5] : "N/A");
#	$annot{$cdhit_id[$i]} = $data[5] ? $data[5] : "N/A";
    }
}

$sth->finish();
exit;

print "name\tstart\tend\tstrand\tstrain\tcdhit_id\n";
foreach my $i (0 .. $#strain) {
    $sth1->execute($strain[$i],$start[$i],$strain[$i],$start[$i]);
    while (my @data = $sth1->fetchrow()){
       	print join "\t", $data[0],$data[1],$data[2],$data[3],$data[4],($data[5] ? $data[5] : "");
	print "\n";
    }
}

$sth1->finish();
$dbh->disconnect();

