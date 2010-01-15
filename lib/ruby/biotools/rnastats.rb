
require 'rnafold'

class RNAStats

  include RNAfold

  def initialize seq=nil, utr5=nil, utr3=nil, templist=nil
    if seq
      @seq = seq.seq
      @id = seq.id
      if seq and utr5 and utr3
        @seq = utr5.sequence.seq+@seq+utr3.sequence.seq
      end
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
    print "\n"
  end
end
