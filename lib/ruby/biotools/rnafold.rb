# Module runs external Vienna RNAfold binary and fetches energy
# and sequence information

module RNAfold

  RNAFOLD_BINARY  = ['/opt/ViennaRNA-2.0.7/bin/RNAfold',
                     '/opt/ViennaRNA-2.1.2/bin/RNAfold']

  # Run RNAfold at a certain energyerature and return the 
  # resulting buffer
  def fold_info_buf seq, energy
    binary = RNAFOLD_BINARY.map { | bin |
      if File.exist?(bin)
        bin
      elsif File.exist?(ENV['HOME'] + bin)
        ENV['HOME'] + bin
      else
        nil
      end
    }.compact[0]
      
    cmd = "echo #{seq} |"+binary+" -T #{energy} --noPS"
    $stderr.print cmd,"\n" if $debug
    result = `#{cmd}` 
    p [:foldinfo,result] if $debug
    result
  end

  # Return the folding pattern
  def fold_pattern buf
    fold_str, energy = RNAfold::parse_rnafold(buf)
    fold_str
  end

  def fold_energy buf
    fold_str, energy = RNAfold::parse_rnafold(buf)
    return nil if not energy
    energy.to_f
  end

  def calc_energy seq, energy
    result = fold_info_buf(seq, energy)
    fold_energy(result)
  end

private

  def RNAfold::parse_rnafold info
    (seq,fold) = info.strip.split(/\n/)
    # p fold
    fold =~ /(.*)\((\s?[\d\.-]+)\)$/
    fold_str = $1
    energy = $2
    fold_str = fold_str.strip if fold_str
    return fold_str,energy
  end
end
