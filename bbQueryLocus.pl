#!/usr/bin/perl                                                                
##This script takes 1st column of file input to use as query.
use strict;
use warnings;
use DBI;
use Data::Dumper;

my (@cdhit_id, @sum, @start);
while (<>) {
    chomp;
    my @fields = split /\t/, $_;
    push @cdhit_id, $fields[0];
}


my $dbh = DBI->connect("dbi:Pg:dbname=bb3-dev;host=Borreliabase.org","", "") or die "Couldn't connect to database: " . DBI->errstr;

#my $sth = $dbh->prepare("select cdhit_id, locus from vorf3 where cdhit_id = ? and group_id = 1 limit 1");

my $sth = $dbh->prepare("select v.cdhit_id, v.locus,v.strain, v.start, v.stop, a.anno_text from vorf3 as v full join fam_annot as a on v.cdhit_id = a.cdhit_id where v.cdhit_id= ? and v.group_id=1 limit 1");

my $sth2 = $dbh->prepare("select cdhit_id, count(case when genome_id < 1000 then 1 end) as lyme, count(case when genome_id >1000 then 1 end) as rf from vorf3 where cdhit_id = ? and group_id = 1 group by cdhit_id order by cdhit_id");

my $sth3 = $dbh->prepare("select count(start) from vorf3 where cdhit_id = ? and start < ?");

my $sth4 = $dbh->prepare("(select locus, cdhit_id, start, stop, strand from vorf3 where cdhit_id = ? and start < ?  order by start offset ?) union (select locus, cdhit_id, start, stop, strand from vorf3 where cdhit_id = ? and start >= ? order by start limit 5) order by start");


my %tmp;
#print "cdhit_id\tlocus\tvariable\tvalue\tanno\n";
#print "cdhit_id\tlocus\tlyme\trf\tstart\tstop\tanno\n";
foreach my $i (0 .. $#cdhit_id) { 
	$sth->execute($cdhit_id[$i]); 
	$sth2->execute($cdhit_id[$i]);
    while (my @data = $sth->fetchrow()){
	while (my @d = $sth2->fetchrow()){

	    print "$data[0]\t$data[1]\t$d[1]\t$d[2]\t$data[2]\t$data[3]\t$data[4]\t" , ($data[5] ? $data[5] : 'N/A'), "\n";
#	    push @start, $data[2];

#	    print "$data[0]\t$data[1]\tlyme\t$d[1]\t$data[2]\n";
#	    print "$data[0]\t$data[1]\trf\t$d[2]\n";
	}
    }    
}
$sth->finish();
$sth2->finish();
exit;
foreach my $i (0 .. $#cdhit_id) { 
    $sth3->execute($cdhit_id[$i],$start[$i]);
    while (my @data = $sth3->fetchrow()){
	push @sum, $data[0] - 5;
#	print ($data[0] ? $data[0] : next);
#        print "\n";
    }
}
$sth3->finish();

print "cdhit_id\tstart\tstop\n";
foreach my $i (0 .. $#cdhit_id) { 
    $sth4->execute($cdhit_id[$i],$start[$i],$sum[$i],$cdhit_id[$i],$start[$i]);
    while (my @data = $sth4->fetchrow()){
	print "$data[0]\t$data[1]\t$data[2]\t\n";
#	print "$data[0]\t$data[1]\t$data[2]\t$data[3]\t$data[4]\n";
    }
}
$sth4->finish();
$dbh->disconnect();







