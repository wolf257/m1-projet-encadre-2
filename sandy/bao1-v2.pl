#/usr/bin/perl
<<DOC; 
Votre Nom : DUCHEMIN Sandy
2018-2019
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

open(FICOUT, ">:encoding(utf8)", "./TEST/sortie-texte-$rubrique.txt") or die("Problème à l\'ouverture");
open(FICOUTXML, ">:encoding(utf8)", "./TEST/sortie-xml-$rubrique.xml") or die("Problème à l\'ouverture");

print FICOUTXML "<?xml version=\"1.0\" encoding=\"utf8\" ?>\n";
print FICOUTXML "<racine>\n";
#----------------------------------------

&parcoursarborescencefichiers($rep);	#recurse!

#----------------------------------------
print FICOUTXML "</racine>";
close(FICOUT);
close(FICOUTXML);
exit;

#---------------FONCTIONS-----------------
sub parcoursarborescencefichiers {
    my $path = shift(@_);
    opendir(DIR, $path) or die "can't open $path: $!\n";
    my @files = readdir(DIR);
    closedir(DIR);
    foreach my $file (@files) {
        next if $file =~ /^\.\.?$/; #on s'assure que $file n'est pas un des répertoire cachés . ou ..
        $file = $path."/".$file;
        if (-d $file) { #"si $file est un répertoire"
            &parcoursarborescencefichiers($file);	#recurse!
        }
        if (-f $file) { #si $file est un fichier
    #       TRAITEMENT à réaliser sur chaque fichier
            if ($file=~/$rubrique.+\.xml$/) {
                print $i++," : $file\n";
                open(FICIN, "<:encoding(utf8)", $file) or die("Problème à l\'ouverture de $file");

                my $ens_ligne;
                
                while (my $line = <FICIN>) {
                chomp $line; #enlève les sauts de ligne
                $ens_ligne .= " $line";}

                while ($ens_ligne =~ /$motif/g) {
                    my $titre = $1;
                    my $description = $2;
                    ($titre, $description) = &clean($titre, $description);
                    if ( !(exists $doublons{$titre}) ) {

                        $doublons{$titre} = 0;
                        print FICOUT "$titre\n";
                        print FICOUT "$description\n\n";

                        print FICOUTXML "\t<item>\n";
                        print FICOUTXML "\t\t<titre> $titre </titre>\n";
                        print FICOUTXML "\t\t<description> $description </description>\n";
                        print FICOUTXML "\t</item>\n\n";
                    }
                }
            }
        }
        }
}

sub clean {
    my ($var, $var2) = @_;
    $var .= ".";
    $var1 =~ s/&#38;#39;/'/g; #on remplace les codes sales par ce qui correspond
    return $var, $var2;
}
#----------------------------------------------
