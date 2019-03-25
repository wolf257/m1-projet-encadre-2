#!/usr/bin/perl
use utf8;
binmode STDOUT, ":utf8";

my$filetalismane=$ARGV[0];
my$filetermino=$ARGV[1];

open my $fileT, "<:encoding(UTF-8)", $filetalismane;
my %dicotmp=();

while(my $ligne = <$fileT>) {
    next if ($ligne =~ /££/) or ($ligne =~ /^##/) or ($ligne =~ /^$/);
    print $ligne;
    if ($ligne !~ /^[^\t]+\t§/) {
        $ligne =~/^(\d+)\t(.+)$/;
        my $cle = $1;
        my $reste = $2;
        my@listereste = split(/\t/, $reste);
        $phtmp.=$reste;
        $dicotmp{$cle} = \@listereste;
        
    }
    else{
        print $phtmp, "\n";
        $dicotmp = ();
        $phtmp = "";
    }
    
    # my $rep=<STDIN>;
}