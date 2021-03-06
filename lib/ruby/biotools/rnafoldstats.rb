
module RNAfoldStats

  def linked buf
    buf.count("(") + buf.count(")")
  end

  def unlinked buf
    buf.count(".")  # not used for stats
  end

  # linked stretches between eyes (formerly islands) is 
  # the count switching into '(' or ')' - so count
  # (),)(,.(,.),(.,).

  def stretches buf
    # buf.split(/\.+/).size
    s = buf.gsub(/\s+/,"")
    (s.scan(/[^(]\(/) + s.scan(/[^)]\)/)).size
  end

  def avg_stretch_size buf
    linked(buf).to_f/stretches(buf)
  end

end

if $UNITTEST

  class Test_RNAfoldStats < Test::Unit::TestCase
    include RNAfoldStats

    FOLD = '...((((((((((((.(((..((((((........(((((.(......).........(((((((.((...(((((((..(((((...(((((.....)))))..).)))).))))))).)).)))))))..(((.....))).))))).........)))))).)))))))))))))))...'

    FOLD2 ='((((((((((.........))))))))))((((((((((((((.((....((((((.......((((((......((((........)))).(((((((((((((.(((((((((....))))))........(((((((..((((.((((....(((((((((((...((((.(((((((.(((..((((((.((.((((((((((..........)))....))))))).)).)))).))(((((.((((..((((......))))((((..((.((..((......))..))..))..)))))))).))))).)))))))))).)))).(((((((.....)))))))....)))))))).....)))...))))..............((((((...(((..(((((((..............((((((......)))))).....(((..((((...............))))..))).......((..((((..((((.....))))))))..))....)))))))..))).))))))))))..))).))))((((........((((((..(((...(((................(((.((..............)).)))....((((.(((......)))...))))...)))..)))..))))))........)))).................(((....))).)))))))))))))..))).(((((...)))))))))))......))))))(((((..((...))..))))).....)))))).))))...))))))((((((.....(((..(((...)))..))).....))))))...........'

    def test_linked
      assert_equal(0,unlinked("()"))
      assert_equal(1,unlinked("(.)"))
      assert_equal(0,linked("."))
      assert_equal(71,unlinked(FOLD))
      assert_equal(112,linked(FOLD))
      assert_equal(372,unlinked(FOLD2))
      assert_equal(492,linked(FOLD2))
      assert_equal(246,FOLD2.count(')'))
      assert_equal(246,FOLD2.count('('))
      assert_equal(372,FOLD2.count('.'))
    end
   
    def test_stretches
      assert_equal(2,stretches("(.)"))
      assert_equal(3,stretches(".(.)"))
      assert_equal(3,stretches(".(.)."))
      assert_equal(23,stretches(FOLD))
      assert_equal(95,stretches(FOLD2))
    end

    def test_stretchesize
      assert_equal(1,avg_stretch_size("(.)"))
      assert_equal("4.8695652173913",avg_stretch_size(FOLD).to_s)
      assert_equal("5.17894736842105",avg_stretch_size(FOLD2).to_s)
    end
  end

end
