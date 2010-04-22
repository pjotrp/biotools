#! /bin/sh

# sets="IL-10 IL-15 IL-4 TGFb1"
sets="IL-10"
freqs="A3 C3 Equal G3 PC T3"

if [ ! -z $simulate ] ; then
  for seq in $sets ; do 
    seqfn=fasta/$seq.txt
    echo "== $seq ($seqfn)"
    for freq in $freqs ; do
      echo ++ $freq
      if [ ! -e $seq.txt_$freq.txt_s9999_i1000.fa ] ; then
        ruby -I ~/izip//git/opensource/bigbio/lib -I ../../../bioruby/lib/ ../../bin/simulate_codons --freq freq/$freq.txt $seqfn &
        echo finished $seq+$freq
      fi
    done
  done
  echo "Waiting..."
  sleep 120
fi

echo Run calculations in parallel
for seq in $sets ; do 
  for freq in $freqs ; do
    fn=$seq.txt_$freq.txt_s9999_i1000.fa
    echo ++ $fn $freq
    ruby -I ~/izip//git/opensource/bigbio/lib -I ../../../bioruby/lib/ ../../bin/mrna_stats --seq fasta/$seq.txt $fn > $fn.csv &
  done
done

