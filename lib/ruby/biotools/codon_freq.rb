# Codon frequencies 
#
# This class reads an EMBOSS cut file, which contains CONDONS, 
# amino acid, the percentage within amino acid, the total 
# frequency (I suppose) and the total number of occurrances in
# the genome:
#
#   GCC    A     0.159    10.375 287181
#
# though it has a relaxed heuristic for lines that have three fields:
#
#   GCC  A       16
#
# note the frequency can be a percentage 0-100, or between 0.0..1.0.
# All other lines are ignored.
#
# The CodonFreq is a list (Array) of mapped items, containing :codon,
# :aminoacid and :freq (0..100)
#
# Copyright (C) 2010 Pjotr Prins <pjotr.prins@thebird.nl> 
#

class CodonFreq < Array

  def initialize fn
    is_perc = nil
    print "\nFrequency file: #{fn}\n"
    File.new(fn).each_line do | s |
      # some heuristic for recognizing fields
      s = s.strip
      next if s =~ /^\#/ or s.size == 0
      fields = s.split
      next if fields.size != 3 and fields.size != 5
      next if fields[0].size != 3
      next if fields[1].size != 1
      list = { :codon => fields[0], :aminoacid => fields[1] }
      freq = fields[2].to_f
      if freq>0.0 and freq<1.0
        is_perc = false if is_perc == nil
        raise "Frequencies inconsistent, <#{s}>" if is_perc == true
        freq = freq*100
      else
        is_perc = true if is_perc == nil
        raise "Frequencies inconsistent, <#{s}>" if is_perc == false
      end
      freq = 100.0 if freq == 1.0 and is_perc

      raise "Frequency out of range #{fields[2]}, <#{s}>" if freq<0.0 or freq>100.0
      list = { :codon => fields[0], :aminoacid => fields[1], :freq => freq  }
      push list if freq != 0.0
    end
    # ascertain all frequencies add up to 100
    validate
  end

  def pretty_print
    print "\nCodon frequency table:\n"
    print "\nCodon|Amino acid|Freq.\n"
    each do | codon |
      print codon[:codon],"\t ",codon[:aminoacid],codon[:freq].to_s.rjust(11),"\n"
    end
  end

  # Validate all frequencies add up to 100%
  def validate
    aas = {}
    each do | codon | 
      aa = codon[:aminoacid]
      aas[aa] = 0.0 if aas[aa] == nil
      aas[aa] += codon[:freq]
    end
    aas.each do | k, v |
      if v <= 99.0 or v > 101.0
        raise "Amino acid #{k} codon frequency adds up to #{v}"
      end
    end
  end

end
