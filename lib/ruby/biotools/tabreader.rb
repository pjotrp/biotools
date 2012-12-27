
class TabSeq
  attr_reader :id, :seq
  def initialize line
    @id,@seq = line.strip.split(/\s/)
  end
end

class TabReader

  def initialize fn
    @f = File.open(fn)
  end

  def each
    @f.each do | line |
      yield TabSeq.new(line)
    end
  end

end
