
module RNAfoldStats

  # Calculated linked nucleotides - referred to by dots. In reality
  # the number of links is half this number
  def linked buf
    buf.count(".")
  end

  def unlinked buf
    buf.size - linked(buf)
  end

  # linked stretches between eyes
  def stretches buf
    buf.split(/\.+/).size
  end

  def avg_stretch_size buf
    unlinked(buf).to_f/stretches(buf)
  end

end

if $UNITTEST

  class Test_RNAfoldStats < Test::Unit::TestCase
    include RNAfoldStats

    FOLD = '...((((((((((((.(((..((((((........(((((.(......).........(((((((.((...(((((((..(((((...(((((.....)))))..).)))).))))))).)).)))))))..(((.....))).))))).........)))))).)))))))))))))))...'

    def test_linked
      assert_equal(2,unlinked("()"))
      assert_equal(2,unlinked("(.)"))
      assert_equal(1,linked("."))
      assert_equal(112,unlinked(FOLD))
      assert_equal(71,linked(FOLD))
    end
   
    def test_stretches
      assert_equal(2,stretches("(.)"))
      assert_equal(3,stretches(".(.)"))
      assert_equal(3,stretches(".(.)."))
      assert_equal(23,stretches(FOLD))
    end

    def test_stretchesize
      assert_equal(1,avg_stretch_size("(.)"))
      assert_equal("4.8695652173913",avg_stretch_size(FOLD).to_s)
    end
  end

end
