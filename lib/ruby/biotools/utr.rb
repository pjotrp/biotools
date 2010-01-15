# UTR handler
#

class UTR

  attr_reader :sequence
  def initialize iseqs, type
    iseqs.each do | seq |
      if seq.id =~ /utr/i and seq.id =~ /#{type}/
        @sequence = seq
        break
      end
    end
  end

end

