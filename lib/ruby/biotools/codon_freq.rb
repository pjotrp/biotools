# Codon frequencies
#
# Copyright (C) 2010 Pjotr Prins <pjotr.prins@thebird.nl> 
#

class CodonFreq < Array

  def initialize fn
    print "\nFrequency file: #{fn}\n"
    File.new(fn).each_line do | s |
      s = s.strip
      next if s =~ /^\#/ or s.size == 0
      fields = s.split
      list = { :codon => fields[0], :aminoacid => fields[1], :freq => fields[2].to_f*100  }
      push list
    end
    # ascertain all frequencies add up to 100
  end

  def pretty_print
    print "\nCodon frequency table:\n"
    print "\nCodon|Amino acid|Freq.\n"
    each do | codon |
      print codon[:codon],"\t ",codon[:aminoacid],codon[:freq].to_s.rjust(11),"\n"
    end
  end

end
