# Fetch and print RNA statistics - including folding characteristics

require 'rnafold'
require 'rnafoldstats'
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
      rnafold_buf = fold_info_buf(seq,t)  # run rnafold
      e1 = fold_energy(rnafold_buf)
      pattern = fold_pattern(rnafold_buf)

      rec = { :temp => t, :energy => e1, :fold => pattern, :size => seq.size, :linked => linked(pattern), :stretches => stretches(pattern), :avg_stretch_size => avg_stretch_size(pattern) }
      push rec
    end
  end

  # For each temperature print the fold sequence information: 
  #   size, linked, stretches, avg_stretch_size
  def pretty_print
    each do | fold |
      print "\t",fold[:size]
    end
    each do | fold |
      print "\t",fold[:linked]
    end
    each do | fold |
      print "\t",fold[:stretches]
    end
    each do | fold |
      print "\t",fold[:avg_stretch_size]
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

  def initialize seq=nil, utr5=nil, utr3=nil, templist=nil, stepsize=nil, stepnum=nil, no_fold=nil
    @stepsize = stepsize
    @stepnum  = stepnum
    @no_fold  = no_fold
    if seq
      @seq = seq.seq
      @id = seq.id
      @expr = seq.expr if seq.expr # optional value
      @base_seq = @seq.dup
      if seq and utr5 and utr3
        @seq = utr5.sequence.seq+@seq+utr3.sequence.seq
      else
        @seq = seq.utr5 + @seq if seq.utr5
        @seq = @seq + seq.utr3 if seq.utr3
      end
      @bioseq = Bio::Sequence::NA.new(@base_seq)  # sequence without UTRs
    end
    @templist = templist
    @templist = ["37"] if templist == nil

    @codontable = Bio::CodonTable[1]
  end

  def print_title
    print "\n#"
    print "\tlen"
    print "\texpr" if @expr
    if not @no_fold
      @templist.each do | t |
        print "\tlen@",t,"C"
      end
      @templist.each do | t |
        print "\tlinked@",t,"C"
      end
      @templist.each do | t |
        print "\tstretches@",t,"C"
      end
      @templist.each do | t |
        print "\tstretch_size@",t,"C"
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
    end
    print "\t%A\t%T\t%G\t%C\t%GC\tGC1\tGC2\tGC3"
    # print "\tA1\tA2\tA3\tT1\tT2\tT3\tG1\tG2\tG3\tC1\tC2\tC3"
    print "\tA1\tT1\tG1\tC1\tA2\tT2\tG2\tC2\tA3\tT3\tG3\tC3"
    CODONS.each do | codon |
      print "\t#{codon}"
    end
    print "\n"
  end

  def pretty_print
    return if @seq == nil or @seq.size < 18
    print @id
    print "\t",@seq.size
    print "\t",@expr if @expr
    if not @no_fold
      rnafolds = RNAfolds.new(@seq, @templist)
      rnafolds.pretty_print

      # energy of subsections (take the max for now)
      temperature = @templist.max
      full_e = rnafolds.energy(temperature)
      (1..@stepnum).each do | i |
        seq = @seq[i*@stepsize..-1]
        e1 = calc_energy(seq,@templist.max)
        if e1
          # e1,seq,@templist
          dE = full_e - e1
          printf "\t%.2f",dE.abs
        else
          print "\t-"
        end
      end
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
    $stdout.flush
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
    # $stderr.print "WARN: Problem with size #{seq.size}!=#{nseq.size*3}\n" if seq.size != nseq.size * 3
    Bio::Sequence::NA.new(nseq).gc_percent
  end

  # Calculate nuc% at codon offset (1..3); returns string with tab delimited fields
  def nuc_codon_percs
    result = ''
    seq = @bioseq.seq.to_s.upcase
    codons = seq.scan(/\S\S\S/)

    # split into codons
    (0..2).each do | position |
      count = { "A" => 0, "G" => 0, "C" => 0, "T" => 0, "N" => 0, "M" => 0, "W" => 0, "K" => 0, "Y" => 0, "S" => 0}
      codons.each do | codon |
        nuc = codon[position]
        if count[nuc] == nil
          p ["WARNING: NO MATCH FOR",codon[position],codon,seq]
          count[nuc] = 0
        else
          count[nuc] += 1
        end
      end
      len3 = count["A"] + count["G"] + count["C"] + count["T"]
      result += "\t"+(count["A"]*100.0/len3).to_i.to_s
      result += "\t"+(count["T"]*100.0/len3).to_i.to_s
      result += "\t"+(count["G"]*100.0/len3).to_i.to_s
      result += "\t"+(count["C"]*100.0/len3).to_i.to_s
    end
    result


=begin

    # Slightly different way of doing the same thing:

    # For each codon position calculate 
    (0..2).each do | offset |
      nseq = ""
      index = 0
      seq.each_char { | nuc|
         nseq += nuc if index % 3 == offset
         index += 1
      }
      $stderr.print "WARN: Problem with size #{seq.size}!=#{nseq.size*3}\n" if seq.size != nseq.size * 3
      if nseq.size > 0
        composition = Bio::Sequence::NA.new(nseq).composition
        ['a','t','g','c'].each do | nuc |
          result += "\t"+(composition[nuc]*100.0/nseq.size).to_i.to_s
        end
      end
    end
    result
=end
  end


end
