# Module runs external Vienna RNAfold binary and fetches energy
# and sequence information

module RNAfold

  RNAFOLD_BINARY = '/opt/ViennaRNA-2.0.7/bin/RNAfold'

  def fold_info seq, temp
    cmd = "echo #{seq} |"+RNAFOLD_BINARY+" -T #{temp} --noPS"
    $stderr.print cmd,"\n" if $debug
    result = `#{cmd}` 
    result
  end

  def fold_seq buf
    buf.split[1]
  end

  def fold_energy buf
    buf.strip =~ /\((-?\d+\.\d+\))$/
    $1.to_f
  end

  def calc_energy seq, temp
    result = fold_info(seq, temp)
    fold_energy(result)
  end

end
