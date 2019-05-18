#/usr/bin/perl

<<DOC; 
DUCHEMIN Sandy - GUEYE Ousseynou 2018-2019

Arguments : REPERTOIRE RUBRIQUE
DOC
#-----------------------------------------------------------
# bao3.pl [sortietalismane.txt] [patrons.txt]

use utf8; #nécessaire pour trouver certains caractères utf8, ici : £
use strict;

binmode STDOUT, ":utf8"; #oblige le terminal à afficher proprement l'utf8

my $filetal = $ARGV[0];
my $filepatron = $ARGV[1];

$filetal =~ /sortie-talismane-(\d+).txt/;
my $rubrique = $1;

my %dicoPatron=();
my $nbtoken = 0;
open my $fileT, "<:encoding(UTF-8)", $filetal;

open my $fileP, "<:encoding(UTF-8)", $filepatron;
my @patrons = <$fileP>;
close $fileP;

open my $fileR, ">:encoding(UTF-8)", "./SORTIEBAO3/extraction_results_$rubrique.txt";

my %dicotmp=();
while (my $ligne =<$fileT>) {
    next if ($ligne =~/££|^##/);
    if ($ligne!~/^$/){
        #print $ligne;
        $ligne =~ /^(\d+)\t(.+)$/;
        my $cle = $1;
        #print "cle : $cle\n";
        my $valeur = $2;
        #print "valeur : $valeur\n";
        my @listevaleur=split(/\t/, $valeur);
        $dicotmp{$cle}=\@listevaleur; #on crée une référence vers la liste

    }
    else {
        my $phrase = "";
        my $lenght = keys %dicotmp; #keys renvoit une liste mais comme on déclare un scalaire, keys va plutôt renvoyer la longueur de la liste
        for (my $i=1;$i<=$lenght;$i++) {
            my $LISTE = $dicotmp{$i};
            my @newLISTE=@$LISTE;
            #print "newLISTE : @newLISTE\n";
            my $mot = $newLISTE[0];
            #print "mot : $mot\n";
            my $pos = $newLISTE[2];
            #print "pos : $pos\n";
            $phrase = $phrase.$mot."/".$pos." ";
            #print "$phrase\n";
        }
        foreach my $pat (@patrons) {
            my $patron = $pat;
            #my $patr = $pat;
            chomp($patron);
            #chomp($patr);
            $patron =~ s/([^ ]+)/\[\^ \]+\/$1/g;
            while ($phrase=~/(?=\s($patron))/g){
                my $token = $1;
                $token =~ s/\/[^ ]+//g;
                $dicoPatron{$patron}->{$token}++;
                $nbtoken++;
            }
        }
    %dicotmp=();
    }
}
print $fileR "$nbtoken éléments trouvés\n";
foreach my $patron (keys %dicoPatron) {
	print $fileR "\nType de pattern: ".$patron." \n\n";
	foreach my $terme (sort {$dicoPatron{$patron}->{$b} <=> $dicoPatron{$patron}->{$a} } keys %{$dicoPatron{$patron}}) {
		print $fileR $dicoPatron{$patron}->{$terme}."\t".$terme."\n";
	}
}
close($fileT);
close($fileR);
print "Done."