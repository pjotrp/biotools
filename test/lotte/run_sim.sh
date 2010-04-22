#! /bin/sh

# sets="IL-10 IL-15 IL-4 TGFb1"
sets="IL-10"

for s in $sets ; do 
  seqfn=fasta/$s.txt
  echo == $seqfn
  for freq in freq/* ; do
    echo ++ $freq
    ruby -I ~/izip//git/opensource/bigbio/lib -I ../../../bioruby/lib/ ../../bin/simulate_codons --freq $freq $seqfn 
    echo finished $seqfn+$freq
  done
done

# export x=IL-4.txt_PC.txt_s9999_i1000.fa ; ruby -I ~/izip//git/opensource/bigbio/lib -I ../../../bioruby/lib/ ../../bin/mrna_stats --seq fasta/IL-4.txt $x > $x.csv &
