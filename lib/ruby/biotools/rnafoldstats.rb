
module RNAfoldStats

  # Calculated linked nucleotides - referred to by braces
  def linked buf
    buf.count("(") + buf.count(")")
  end

end

class Test_RNAfoldStats < Test::Unit::TestCase
  include RNAfoldStats

  def test_linked
    assert_equal(2,linked("()"))
    assert_equal(2,linked("(.)"))
  end
 
end


