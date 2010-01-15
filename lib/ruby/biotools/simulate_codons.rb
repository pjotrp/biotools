# Simulate codons
#
# Copyright (C) 2010 Pjotr Prins <pjotr.prins@thebird.nl> 
#

class SimulateCodons

  def initialize aaseq, selector
    @aaseq = aaseq
    @selector = selector
  end

  def simulate fn, descr='SimulateCodons', iterations=1000, validate=false
    File.open(fn,"w") do | f |
      (0..iterations-1).each do | iter |
        show_progress(iter)

        nuc = ''
        @aaseq.each_char do | aa |
          codon = @selector.get_codon(aa)
          nuc += codon
        end
        f.write(">"+descr+" (simulated codons ##{iter+1})\n")
        f.write(nuc+"\n")
      end
    end
  end

  private

  def show_progress iter
    $stderr.print "." if iter % 100 == 0
  end
end

