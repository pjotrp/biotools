#! /bin/sh
#
# Codon simulator
#
# Read a file that contains 4 items: the amino acid sequence, the nucleotide sequence
# and the (untranslated) sequences at the 5' and 3' ends.
#
# Also pick up the simulation and calculate the folding stats.

# seqs="fasta/IL-15.txt fasta/TGFb1.txt"
seqs="fasta/TGFb1.txt"

for seq in $seqs ; do 
  echo == $seq
  for freq in freq/* ; do
    echo ++ $freq
    ruby -I ~/izip//git/opensource/bigbio/lib -I ../../../bioruby/lib/ ../../bin/simulate_codons --freq $freq $seq &
    echo finished $seq+$freq
  done
done

# export x=IL-4.txt_PC.txt_s9999_i1000.fa ; ruby -I ~/izip//git/opensource/bigbio/lib -I ../../../bioruby/lib/ ../../bin/mrna_stats --seq fasta/IL-4.txt $x > $x.csv &
