#! /bin/sh
#

if [ -z $1 ]; then 
  echo EXAMPLE: ./run_stats.sh --seq test/data/fasta/IL-4.fa IL-4_Hs-1.freq_s9999_i10.fa 
fi

echo ruby -I ../bigbio/lib/ bin/mrna_stats $*
ruby -I ../bigbio/lib/ -I ../bioruby/lib bin/mrna_stats $*

