
module RNAfoldStats

  # Calculated linked nucleotides - referred to by braces
  def linked buf
    buf.count("(") + buf.count(")")
  end

  def islands buf
    buf.split(/\.+/).size
  end

  def avg_island_size buf
    linked(buf).to_f/islands(buf)
  end

end

if $UNITTEST

  class Test_RNAfoldStats < Test::Unit::TestCase
    include RNAfoldStats

    FOLD = '...((((((((((((.(((..((((((........(((((.(......).........(((((((.((...(((((((..(((((...(((((.....)))))..).)))).))))))).)).)))))))..(((.....))).))))).........)))))).)))))))))))))))...'

    def test_linked
      assert_equal(2,linked("()"))
      assert_equal(2,linked("(.)"))
      assert_equal(112,linked(FOLD))
    end
   
    def test_islands
      assert_equal(2,islands("(.)"))
      assert_equal(3,islands(".(.)"))
      assert_equal(3,islands(".(.)."))
      assert_equal(23,islands(FOLD))
    end

    def test_islandsize
      assert_equal(1,avg_island_size("(.)"))
      assert_equal("4.8695652173913",avg_island_size(FOLD).to_s)
    end
  end

end
