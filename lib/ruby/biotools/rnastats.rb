
require 'rnafold'
require 'bio'

class RNAStats

  include RNAfold

  def initialize seq=nil, utr5=nil, utr3=nil, templist=nil
    if seq
      @seq = seq.seq
      @id = seq.id
      @base_seq = @seq
      if seq and utr5 and utr3
        @seq = utr5.sequence.seq+@seq+utr3.sequence.seq
      end
      @bioseq = Bio::Sequence::NA.new(@base_seq)
    end
    @templist = templist
    @templist = ["37"] if templist == nil
  end

  def print_title
    print "\n#"
    @templist.each do | t |
      print "\tE@",t,"C"
    end
    if @templist.size == 2
      print "\tdE"
    end
    print "\t%A\t%T\t%G\t%C\t%GC\tGC1\tGC2\tGC3"
    print "\n"
  end

  def pretty_print
    print @id
    e = []
    @templist.each do | t |
      e1 = energy(@seq,t)
      print "\t",e1
      e.push e1
    end
    if e.size == 2
      print "\t",e[1]-e[0]
    end
    print "\t",nucleotide_use('a')
    print "\t",nucleotide_use('t')
    print "\t",nucleotide_use('g')
    print "\t",nucleotide_use('c')
    print "\t",@bioseq.gc_percent
    print "\t",gc(0)
    print "\t",gc(1)
    print "\t",gc(2)
    print "\n"
  end

  def nucleotide_use nuc
    (@bioseq.count(nuc[0].chr).to_f/@bioseq.size*100).to_i
  end

  def gc(offset)
    seq = @bioseq.seq.to_s
    nseq = ""
    index = 0
    seq.each_char { | nuc|
       nseq += nuc if index % 3 == offset
       index += 1
    }
    raise "Problem with size #{seq.size}!=#{nseq.size*3}" if seq.size != nseq.size * 3
    Bio::Sequence::NA.new(nseq).gc_percent
  end

end
