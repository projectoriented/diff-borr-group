#!/usr/bin/perl

use strict;
use warnings;
use DBI;
use Data::Dumper;

my (@cdhit);
my $dbh = DBI->connect("dbi:Pg:dbname=bb3-dev;host=Borreliabase.org","", "") or die "Couldn't connect to database: " . DBI->errstr;

my $sth = $dbh->prepare("select distinct cdhit_id from meitmpcommonality");
my $sth2 = $dbh->prepare("select cdhit_id, count(genome_id > 1000) from meitmpcommonality group by cdhit_id order by cdhit_id");


$sth->execute();
while (my @data = $sth->fetchrow()) { push @cdhit, @data; }
$sth->finish();

$sth2->execute();
my @rs = @{$sth2->fetchall_arrayref()};

my %borrComp = map {$_->[0] => $_->[1] => $_->[2] } @rs;
$sth2->finish();
$dbh->disconnect();

print Dumper \%borrComp;


