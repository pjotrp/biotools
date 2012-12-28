
class TabSeq
  attr_reader :id, :seq, :utr5, :utr3
  def initialize line
    fields = line.strip.split(/\s/)
    if fields.size == 2
      @id,@seq = fields
    else
      @id,@expr,@seq,@utr5,@utr3 = fields
    end
  end
end

class TabReader

  def initialize fn
    @f = File.open(fn)
    @header = @f.gets.strip.split(/\s/)
  end

  def each
    @f.each do | line |
      yield TabSeq.new(line)
    end
  end

end
