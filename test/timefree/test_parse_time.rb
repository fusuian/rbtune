require "minitest/autorun"
require "rbtune/timefree"


class TestParseTime < Minitest::Test
  def setup
  end

  def test_parse_time_normal
    assert_equal Time.local(2022,4,1,12,0), TimeFree.parse_time('4/1', '12:00')
    assert_equal Time.local(2022,4,1,0,0), TimeFree.parse_time('4/1', '0:00')
    assert_equal Time.local(2022,4,1,23,59), TimeFree.parse_time('2022-4-1', '23:59')
    assert_equal Time.local(2022,4,1,12,30), TimeFree.parse_time('22-4-1', '12:30')
    assert_raises { TimeFree.parse_time('4-1', '0:00') }
  end

  def test_parse_time_midnight
    assert_equal Time.local(2022,4,2,0,0), TimeFree.parse_time('2022-04-1', '24:00')
    assert_equal Time.local(2022,4,2,2,30), TimeFree.parse_time('2022-04-1', '26:30')
    assert_equal Time.local(2022,4,2,5,59), TimeFree.parse_time('2022-04-1', '29:59')
    assert_raises { TimeFree.parse_time('2022-04-1', '30:00') }
  end

  def test_parse_time_week_name
    today = Date.today
    day = today - today.wday
    assert_equal Time.local(day.year, day.mon, day.day, 0, 0), TimeFree.parse_time('sun', '0:00')
    day += 1
    day -= 7 if day > today
    assert_equal Time.local(day.year, day.mon, day.day, 0, 0), TimeFree.parse_time('mon', '0:00')
    day += 1
    day -= 7 if day > today
    assert_equal Time.local(day.year, day.mon, day.day, 0, 0), TimeFree.parse_time('tue', '0:00')
    day += 1
    day -= 7 if day > today
    assert_equal Time.local(day.year, day.mon, day.day, 0, 0), TimeFree.parse_time('wed', '0:00')
    day += 1
    day -= 7 if day > today
    assert_equal Time.local(day.year, day.mon, day.day, 0, 0), TimeFree.parse_time('thu', '0:00')
    day += 1
    day -= 7 if day > today
    assert_equal Time.local(day.year, day.mon, day.day, 0, 0), TimeFree.parse_time('fri', '0:00')
    day += 1
    day -= 7 if day > today
    assert_equal Time.local(day.year, day.mon, day.day, 0, 0), TimeFree.parse_time('sat', '0:00')

  end

end
