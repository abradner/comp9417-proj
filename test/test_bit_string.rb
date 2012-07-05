require "test/unit"
require "lib/bit_string"

class TestBitString < Test::Unit::TestCase

  # Called before every test method runs. Can be used
  # to set up fixture information.
  def setup
    # Do nothing
  end

  # Called after every test method runs. Can be used to tear
  # down fixture information.

  def teardown
    # Do nothing
  end

  # Fake test
  def test_encode_decode_match

    bounds = [7,5,3,9]
    selection = [3,4,1,3]

    assert_equal(selection,BitString.decode(bounds,BitString.encode(bounds, selection)).inspect)

  end
end