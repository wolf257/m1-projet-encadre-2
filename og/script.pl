#!/usr/bin/env/ perl -w

# pb possibles :
# - gros bloc contenant toutes les balises.
# - une balise sur 2 lignes.

sub all_lines_into_one {
    my $compteur = 0;
    my $ens_ligne;
    while (my $line = <FICIN>) {
        chomp $line;
        $ens_ligne .= " $line.";
        $compteur++;
    }
    print "Ce fichier comptait $compteur lignes.";
    return $ens_ligne;
}

sub write_xml_header {
    my $fic = shift;
    print $fic "<?xml version=\"1.0\" encoding=\"utf8\" ?>\n";
    print $fic "<racine>\n\n";
}

sub write_xml_tail {
    my $fic = shift;
    print $fic "</racine>";
}

# 1/ Lecture fichier rss en 1 seule ligne (L)
my $fic = shift(@ARGV);

open(FICIN, "<:encoding(utf8)", $fic) or die("message1");
my $ens_ligne = all_lines_into_one(FICIN);
close(FICIN);

# Open files
open(FICOUT, ">:encoding(utf8)", "./sortie-texte.txt") or die("message2");
open(FICOUTXML, ">:encoding(utf8)", "./sortie-xml.xml") or die("message3");

write_xml_header(FICOUTXML);

# 2/ find in L les occurrences de titre et de description
my $motif = "<item>.*?<title>([^<]*)<\/title>.*?<description>([^<]*)</description>.*?</item>";

my $num_art = 0;
while ($ens_ligne =~ /$motif/g) {
    print FICOUT "$1\n";
    print FICOUT "$2\n\n";

    print FICOUTXML "\t<titre num_art=\"$num_art\"> $1 </titre>\n";
    print FICOUTXML "\t<description num_art=\"$num_art\"> $2 </description>\n\n";

    $num_art++;
}

write_xml_tail(FICOUTXML);

# Close files
close(FICOUT);
close(FICOUTXML);
