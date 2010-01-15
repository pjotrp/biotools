
module RNAfold

  RNAFOLD_BINARY = '/opt/ViennaRNA-1.8.4/bin/RNAfold'

  def energy seq, temp
    cmd = "echo #{seq} |"+RNAFOLD_BINARY+" -T #{temp} -noPS"
    result = `#{cmd}` 
    result.strip =~ /\((-?\d+\.\d+\))$/
    $1.to_f
  end

end
