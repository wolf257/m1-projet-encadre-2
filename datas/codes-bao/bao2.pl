#/usr/bin/perl
use utf8;

<<DOC; 
DUCHEMIN Sandy - GUEYE Ousseynou 2018-2019

Arguments : REPERTOIRE RUBRIQUE
DOC
#-----------------------------------------------------------

my $rep="$ARGV[0]";
my $rubrique = "$ARGV[1]";
# on s'assure que le nom du répertoire ne se termine pas par un slash
$rep=~ s/[\/]$//;

# 2/ find in L les occurrences de titre et de description
my $motif = "<item>.*?<title>([^<]*)<\/title>.*?<description>([^<]*)</description>.*?</item>";

my $i = 0;

my @doublons;

open(FICOUT, ">:encoding(utf8)", "./SORTIEBAO2/TTsortie-texte-$rubrique.txt") or die("Problème à l\'ouverture de FICOUT");
open(FICOUTXML, ">:encoding(utf8)", "./SORTIEBAO2/TTsortie-xml-$rubrique.xml") or die("Problème à l\'ouverture de FICOUTXML");

open(TALISMANE, ">:encoding(utf8)", "./SORTIEBAO2/sortie-talismane-$rubrique.txt") or die("Problème à l\'ouverture de TALISMANE");

print FICOUTXML "<?xml version=\"1.0\" encoding=\"utf8\" ?>\n";
print FICOUTXML "<racine>\n";
#----------------------------------------

&parcoursarbre($rep);	#lancement du programme récursif

#----------------------------------------
print FICOUTXML "</racine>";
close(FICOUT);
close(FICOUTXML);
close(TALISMANE);
exit;

#---------------FONCTIONS-----------------
sub parcoursarbre {
    my $path = shift(@_);
    opendir(DIR, $path) or die "can't open $path: $!\n";
    my @files = readdir(DIR);
    closedir(DIR);
    foreach my $file (@files) {
        next if $file =~ /^\.\.?$/; #on s'assure que $file n'est pas un des répertoire cachés..
        $file = $path."/".$file;
        if (-d $file) { #"si $file est un répertoire"
            &parcoursarbre($file);
        }
        if (-f $file) { #si $file est un fichier
    #       TRAITEMENT à réaliser sur chaque fichier
            if ($file=~/$rubrique.+\.xml$/) {
                print "************************************************";
                print "\n",$i++," : $file\n\n";
                print "************************************************";
                open(FICIN, "<:encoding(utf8)", $file) or die("Problème à l\'ouverture de $file");

                my $ens_ligne;
                
                while (my $line = <FICIN>) {
                chomp $line; #enlève les sauts de ligne
                $ens_ligne .= " $line";}

                my $fortalis="";

                while ($ens_ligne =~ /$motif/g) {
                    my $titre = $1;
                    my $description = $2;
                    ($titre, $description) = &clean($titre, $description);
                    if ( !(exists $doublons{$titre}) ) {

                        $doublons{$titre} = 1;

                        my $titreTal = $titre;
                        my $descriptionTal = $description;
                        $titreTal =~ s/([.\…\?\!]+)/$1\n\n/g;
                        $descriptionTal =~ s/([.\…\?\!]+)/$1\n\n/g;
                        $fortalis = $fortalis . $titreTal . "\n\n" . $descriptionTal . "\n\n";
                        print FICOUT "$titre\n";
                        print FICOUT "$description\n\n";

                        print FICOUTXML "\t<item>\n";
                        my ($titreTT,$descriptionTT) = &etiquetageTT($titre, $description);
                        print FICOUTXML "\t\t<titre> $titreTT </titre>\n";
                        print FICOUTXML "\t\t<description> $descriptionTT </description>\n";
                        print FICOUTXML "\t</item>\n\n";
                    }
                    else {
                        $doublons{$titre}++;
                    }
                }
                my $etiquetTa = &etiquetageTalismane($fortalis);
				print TALISMANE "$etiquetTa";
            }
        }
        }
}

#********************FONCTIONS*************************

sub clean {
    my ($var, $var2) = @_;
    $var .= ".";
    $var1 =~ s/&#38;#39;/'/g; #on remplace les codes sales par ce qui correspond
    return $var, $var2;
}
#----------------------------------------------
sub etiquetageTT {


	my $vartitre = $_[0];
	my $vardesc = $_[1];
	my $titretagge;
	my $descriptiontagge;
	open (TMP, ">:encoding(utf8)", "SORTIEBAO2/temp.txt");
	print TMP $vartitre ;
	close TMP;
	system("perl5.16.3.exe SCRIPTS/tokenise-utf8.pl -f SORTIEBAO2/temp.txt | tree-tagger.exe -token -lemma -no-unknown TREETAGGER/french-oral-utf-8.par > SORTIEBAO2/temp_tag.txt");
	system("perl5.16.3.exe SCRIPTS/treetagger2xml-utf8.pl SORTIEBAO2/temp_tag.txt utf8");
	{
        local $/=undef;
        open(FIC1, "<:encoding(utf8)", "SORTIEBAO2/temp_tag.txt.xml");
        $titretagge = <FIC1>;
        close FIC1;
        $titretagge =~ s/<\?xml.+?>//;
	}

	open (TMP, ">:encoding(utf8)", "SORTIEBAO2/temp.txt");
	print TMP $vardesc ;
	close TMP;
	system("perl5.16.3.exe SCRIPTS/tokenise-utf8.pl -f SORTIEBAO2/temp.txt | tree-tagger.exe -token -lemma -no-unknown TREETAGGER/french-oral-utf-8.par > SORTIEBAO2/temp_tag.txt");
	system("perl5.16.3.exe SCRIPTS/treetagger2xml-utf8.pl SORTIEBAO2/temp_tag.txt utf8");
	{
        local $/=undef;
        open(FIC1, "<:encoding(utf8)", "SORTIEBAO2/temp_tag.txt.xml");
        $descriptiontagge = <FIC1>;
        $descriptiontagge =~ s/<\?xml.+?>//;
        close FIC1;
	}
    print "$vartitre\n";
	return $titretagge, $descriptiontagge;
}
#----------------------------------------------------
sub etiquetageTalismane {

    my $var = shift @_;
    open (TMP, ">:encoding(utf8)", "./SORTIEBAO2/entree_talismane.txt" );
    print TMP $var;
    close TMP;
    system ("java -Xmx1G -Dconfig.file=../TALISMANE/talismane-fr-5.0.4.conf -jar ../TALISMANE/talismane-core-5.1.2.jar --analyse --sessionId=fr --encoding=UTF8 --inFile=./SORTIEBAO2/entree_talismane.txt --outFile=./SORTIEBAO2/sortie_talismane.tal");
    my $lefil;
    {
        local $/=undef;
        open(FIC1, "<:encoding(utf8)", "./SORTIEBAO2/sortie_talismane.tal");
        $lefil = <FIC1>;
        close FIC1;
    }
    return $lefil;

}