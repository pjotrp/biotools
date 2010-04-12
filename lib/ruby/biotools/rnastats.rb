# Fetch and print RNA statistics - including folding characteristics

require 'rnafold'
require 'bio'

# Calculate and record fold statistics. 
#
# The size of the fold is calculated by removing all loops containing only dots 
# (nucleotides) - so remove anything between single braces: (....). Next all 
# braces are removed. So:
#
#   sequence              remove main loops
#   ...(((...)))...    -> ...(())... -> ......   (length is 6)
#   ...(..((...).))... -> ...(())... -> ......   (length is also 6)
#
# To count the total loops simply the left braces are counted.
#
class RNAfolds < Array
  include RNAfold
  include RNAfoldStats

  # Run rnafold to fetch energy and fold sequence
  def initialize seq, templist
    templist.each do | t |
      result = fold_info(seq,t)
      e1 = fold_energy(result)
      # p result
      # short = result.gsub(/\(\.+\)/,'').gsub(/[\(\)]/,'')
      # p [short,short.size]
      rec = { :temp => t, :energy => e1, :fold => fold_seq(result), :size => result.size, :loops => result.count("("), :linked = linked(result), :islands = islands(result), :avg_island_size = avg_island_size(result) }
      push rec
      # @maxtemp = t if @maxtemp==nil or @maxtemp<t
    end
  end

  # For each temperature print the fold sequence information: 
  #   linked, islands, avg_island_size
  def pretty_print
    each do | fold |
      print "\t",fold[:size]
    end
    each do | fold |
      print "\t",fold[:loops]
    end
    e = []
    each do | fold |
      print "\t",fold[:energy]
      e.push fold[:energy]
    end
    if e.size > 1
      print "\t",e[1]-e[0]
    end
  end

  def energy(temp)
    each do | fold |
      return fold[:energy] if fold[:temp]==temp
    end
  end
end

class RNAStats
  include RNAfold

  CODONS = %w{ GCA GCC GCG GCT TGC TGT GAC GAT GAA GAG TTC TTT GGA GGC GGG GGT CAC CAT ATA ATC ATT AAA AAG CTA CTC CTG CTT TTA TTG ATG AAC AAT CCA CCC CCG CCT CAA CAG AGA AGG CGA CGC CGG CGT AGC AGT TCA TCC TCG TCT ACA ACC ACG ACT GTA GTC GTG GTT TGG TAC TAT TAA TAG TGA }

  def initialize seq=nil, utr5=nil, utr3=nil, templist=nil, stepsize=nil, stepnum=nil
    @stepsize = stepsize
    @stepnum  = stepnum
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

    @codontable = Bio::CodonTable[1]
  end

  def print_title
    print "\n#"
    print "\tlen"
    @templist.each do | t |
      print "\tlen@",t,"C"
    end
    @templist.each do | t |
      print "\tloops@",t,"C"
    end
    @templist.each do | t |
      print "\tE@",t,"C"
    end
    if @templist.size == 2
      print "\tdE"
    end
    (1..@stepnum).each do | i |
      print "\t#{i*@stepsize}AA@#{@templist.max}C"
    end
    print "\t%A\t%T\t%G\t%C\t%GC\tGC1\tGC2\tGC3"
    print "\tA1\tA2\tA3\tT1\tT2\tT3\tG1\tG2\tG3\tC1\tC2\tC3"
    CODONS.each do | codon |
      print "\t#{codon}"
    end
    print "\n"
  end

  def pretty_print
    print @id
    print "\t",@seq.size
    rnafolds = RNAfolds.new(@seq, @templist)
    rnafolds.pretty_print

    # energy of subsections (take the max for now)
    temperature = @templist.max
    full_e = rnafolds.energy(temperature)
    (1..@stepnum).each do | i |
      seq = @seq[i*@stepsize..-1]
      e1 = calc_energy(seq,@templist.max)
      dE = full_e - e1
      printf "\t%.2f",dE.abs
    end

    # Codon statistics
    print "\t",nucleotide_use('a')
    print "\t",nucleotide_use('t')
    print "\t",nucleotide_use('g')
    print "\t",nucleotide_use('c')
    print "\t",@bioseq.gc_percent
    print "\t",gc(0)
    print "\t",gc(1)
    print "\t",gc(2)
    print nuc_codon_percs
    
    usage = @bioseq.codon_usage
    # size = @bioseq.size
    CODONS.each do | codon |
      codon = codon.downcase
      if usage[codon] != nil and usage[codon] > 0.0
        aa = @codontable[codon]
        family = @codontable.revtrans(aa) # => ["gcg", "gct", "gca", "gcc"]
        total = 0
        family.each do | c2 |
          total += usage[c2]
        end
        # print "\t",usage[codon],"/#{total}-",
        print "\t",(usage[codon].to_f/total*100+0.00001).to_i
      else
        print "\t-"
      end
    end
    print "\n"
  end

  def nucleotide_use nuc
    (@bioseq.count(nuc[0].chr).to_f/@bioseq.size*100).to_i
  end

  # Calculate GC% at codon offset (1..3)
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

  # Calculate nuc% at codon offset (1..3)
  def nuc_codon_percs
    result = ''
    seq = @bioseq.seq.to_s
    # For each codon position calculate 
    (0..2).each do | offset |
      nseq = ""
      index = 0
      seq.each_char { | nuc|
         nseq += nuc if index % 3 == offset
         index += 1
      }
      raise "Problem with size #{seq.size}!=#{nseq.size*3}" if seq.size != nseq.size * 3
      composition = Bio::Sequence::NA.new(nseq).composition
      ['a','t','g','c'].each do | nuc |
        result += "\t"+(composition[nuc]*100.0/nseq.size).to_i.to_s
      end
    end
    result
  end


end
