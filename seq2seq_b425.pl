#! /usr/bin/perl

#use warnings;
use strict;
use Text::CSV;
use Catmandu::Importer::MARC::ALEPHSEQ;
use Catmandu::Exporter::MARC::ALEPHSEQ;
use Catmandu::Fix::marc_remove as => 'marc_remove';
use Catmandu::Fix::marc_add as => 'marc_add';
use Catmandu::Fix::marc_map as => 'marc_map';

# Unicode-Support innerhalb des Perl-Skripts
use utf8;
# Unicode-Support für Output
binmode STDOUT, ":utf8";

die "Argumente: $0 Input Output \n" unless @ARGV == 2;

my($inputfile,$outputfile) = @ARGV;
my $tempfile = './temp.seq';

open my $in, "<:encoding(UTF-8)", $inputfile or die "$0: open $inputfile: $!";
open my $out, ">:encoding(UTF-8)", $tempfile or die "$0: open $tempfile: $!";

NEWLINE: while (<$in>) {
    my $sysnumber = (substr $_ , 0, 9);
    my $line = $_;
    my $field = (substr $line, 10, 3);
    my $ind1 = (substr $line, 13, 1);
    my $ind2 = (substr $line, 14, 1);
    my $content = (substr $line, 18);
    chomp $line;
    chomp $content;

    my @subfields = split(/\$\$/, $line);
    shift @subfields;

    # Zu löschende Felder entfernen
    if ($field =~ /(591)/) {
        next NEWLINE;
    }
    
    # LDR/17 auf 2 setzen, LDR/19 auf leer setzen
    if ($field =~ /(LDR)/) {
        substr($content,8,1) = '-';
        substr($content,17,1) = '2';
        substr($content,19,1) = '-';
        $line = $sysnumber . ' LDR   L ' . $content;
    }
    
    # Feld 008 anpassen
    if ($field =~ /(008)/) {
        substr($content,6,1) = 'm';
        substr($content,7,4) = '----';
        substr($content,11,4) = '----';
        substr($content,15,3) = 'xx-';
        substr($content,29,2) = '00';
        $line = $sysnumber . ' 008   L ' . $content;
    }

    # Strichcode-Prefix ergänzen 
    if ($field =~ /(949)/) {
        $content =~ s/\$\$b/\$\$bSfGBB/g;
        $line = $sysnumber . ' 949   L ' . $content;
    }

    # Indikatoren in Feld 520 löschen, Unterfeld $5 ergänzen
    if ($field =~ /(520)/) {
        $line = $sysnumber . ' 520   L ' . $content . '$$5B425';
    } 

    # Feld 040 $a in existierendem Feld 040 hinzufügen
    if ($field =~ /(040)/) {
        $content =~ s/\$\$bger\$\$evsb/\$\$aSzZuIDS BS\/BE B425\$\$bger\$\$evsb/g;
        $line = $sysnumber . ' 040   L ' . $content;
    }
    
    print $out $line . "\n";
}

close $out or warn "$0: close $tempfile $!";

my $importer = Catmandu::Importer::MARC::ALEPHSEQ->new(file => $tempfile);
#my $exporter = Catmandu::Exporter::MARC::XML->new(file => $outputfile);
my $exporter = Catmandu::Exporter::MARC::ALEPHSEQ->new(file => $outputfile);

$importer->each(sub {
    my $data = $_[0];

    # Feld 090 mit alter Systemnummer hinzufügen     
    $data = marc_map($data,'001','f001');
    $data = marc_add($data,'090','a', $data->{f001}, 'b', 'FG Kornhaus');
     
    # Feld 019 mit Unikatshinweishinzufügen     
    $data = marc_add($data,'019','a', 'Datenimport FG Kornhaus' , '5', 'B425/2019');

    # Formatbegriffe anpassen
    $data = marc_map($data,'LDR','LDR');
    my $ldrpos6 = substr($data->{LDR}, 6, 1);

    # Feld 336 aufgrund Leader/06
    if ($ldrpos6 =~ /a/ ) {
        $data = marc_add($data,'336','a','Text','b','txt','2','rdacontent');
        $data = marc_add($data,'337','a','ohne Hilfsmittel zu benutzen','b','n','2','rdamedia');
        $data = marc_add($data,'338','a','Band','b','nc','2','rdacarrier');
    } elsif ($ldrpos6 =~ /g/ ) {
        $data = marc_add($data,'336','a','zweidimensionales bewegtes Bild','b','tdi','2','rdacontent');
        $data = marc_add($data,'337','a','video','b','v','2','rdamedia');
        $data = marc_add($data,'338','a','Videodisk','b','vd','2','rdacarrier');
    } elsif ($ldrpos6 =~ /i/ ) {
        $data = marc_add($data,'336','a','gesprochenes Wort','b','spw','2','rdacontent');
    } elsif ($ldrpos6 =~ /j/ ) {
        $data = marc_add($data,'336','a','aufgeführte Musik','b','prm','2','rdacontent');
    } elsif ($ldrpos6 =~ /m/ ) {
        $data = marc_add($data,'336','a','Text','b','txt','2','rdacontent');
        $data = marc_add($data,'337','a','Computermedien','b','c','2','rdamedia');
        $data = marc_add($data,'338','a','Computerdisk','b','cd','2','rdacarrier');
    }
 
    #Feld 001 löschen 
    $data = marc_remove($data,'001');

    $exporter->add($data);
});

$exporter->commit;


exit;

