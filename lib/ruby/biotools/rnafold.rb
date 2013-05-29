# Module runs external Vienna RNAfold binary and fetches energy
# and sequence information

module RNAfold

  RNAFOLD_BINARY  = ['/opt/ViennaRNA-2.0.7/bin/RNAfold',
                     '/opt/ViennaRNA-2.1.2/bin/RNAfold']

  # Run RNAfold at a certain temperature and return the 
  # resulting buffer
  def fold_info_buf seq, temp
    binary = RNAFOLD_BINARY.map { | bin |
      if File.exist?(bin)
        bin
      elsif File.exist?(ENV['HOME'] + bin)
        ENV['HOME'] + bin
      else
        nil
      end
    }.compact[0]
      
    cmd = "echo #{seq} |"+binary+" -T #{temp} --noPS"
    $stderr.print cmd,"\n" if $debug
    result = `#{cmd}` 
    p [:foldinfo,result] if $debug
    result
  end

  # Return the folding pattern
  def fold_pattern buf
    RNAfold::parse_rnafold(buf)[0]
  end

  def fold_energy buf
    # buf.strip =~ /\((-?\d+\.\d+\))$/
    RNAfold::parse_rnafold(buf)[0].to_f
  end

  def calc_energy seq, temp
    result = fold_info_buf(seq, temp)
    fold_energy(result)
  end

private

  def RNAfold::parse_rnafold info
    (seq,fold) = info.strip.split(/\n/)
    # p fold
    fold =~ /(.*)\(([\d\.-]+)\)$/
    return $1.strip,$2
  end
end
