#! /bin/sh

for seq in fasta/IL-15.txt fasta/TGFb1.txt ; do 
  echo $seq
  for freq in freq/* ; do
    echo ++ $freq
    ruby -I ~/izip//git/opensource/bigbio/lib -I ../../../bioruby/lib/ ../../bin/simulate_codons --freq $freq $seq &
  done
done


# export x=IL-4.txt_PC.txt_s9999_i1000.fa ; ruby -I ~/izip//git/opensource/bigbio/lib -I ../../../bioruby/lib/ ../../bin/mrna_stats --seq fasta/IL-4.txt $x > $x.csv &
