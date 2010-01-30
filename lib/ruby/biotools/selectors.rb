# Codon selectors
#
# Copyright (C) 2010 Pjotr Prins <pjotr.prins@thebird.nl> 
#
# Simulated codons for aa sequences

# Simply pulls random codons from the frequency table
class SimpleRandomCodon
  def initialize aaseq, freq_table
    # create buckets
    aalist = {}
    freq_table.each do | codon |
      aa = codon[:aminoacid]
      aalist[aa] = {} if aalist[aa]==nil
      aalist[aa][codon[:codon]] = codon[:freq]
    end
    @table = {}
    aalist.each do | aa, codonfreq |
      bucket = {}   # {"K"=>{49..100=>"AAG", 0..48=>"AAA"}
      first = 0
      codonfreq.each do | codon, freq |
        last = first+freq.to_i
        bucket[first..last] = codon
        first = last+1
      end
      @table[aa] = bucket
    end
  end

  def get_codon aa
    bucket = @table[aa]
    raise "Unknown codon #{aa}" if bucket == nil
    i = rand(100)  # value in 0..99
    bucket.each do | range, codon |
      return codon if range.member? i
    end
    get_codon aa
  end
end
