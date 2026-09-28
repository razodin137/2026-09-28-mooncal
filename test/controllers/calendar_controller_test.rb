require "test_helper"

class CalendarControllerTest < ActionDispatch::IntegrationTest
  test "shows the current week and following weeks" do
    travel_to Date.new(2026, 9, 28) do
      get root_url

      assert_response :success
      assert_select ".calendar-week", count: 5
      first_day = Date.new(2026, 9, 27)
      assert_select ".calendar-week[data-start-date=?]", first_day.iso8601
      assert_select ".calendar__header span", text: "Sun"
    end
  end

  test "does not render weeks before today" do
    travel_to Date.new(2026, 9, 28) do
      get root_url

      assert_select ".calendar-week" do |weeks|
        starts = weeks.map { |week| Date.parse(week["data-start-date"]) }
        assert starts.all? { |start| start >= Date.current.beginning_of_week(:sunday) }
      end
    end
  end

  test "weeks action appends newer weeks after the anchor" do
    anchor = Date.current.beginning_of_week(:sunday)

    get calendar_weeks_url(date: anchor.iso8601, direction: "newer")

    assert_response :success
    assert_select ".calendar-week", count: 5
    assert_select ".calendar-week[data-start-date=?]", (anchor + 7.days).iso8601
  end

  test "rejects an invalid direction" do
    get calendar_weeks_url(date: Date.current.iso8601, direction: "sideways")

    assert_response :bad_request
  end

  test "rejects a malformed anchor" do
    get calendar_weeks_url(date: "not-a-date", direction: "newer")

    assert_response :bad_request
  end

  test "marks the month on its first day" do
    anchor = Date.new(2024, 1, 28) # Week of Jan 28: newer batch runs Feb 4 through Mar 10

    get calendar_weeks_url(date: anchor.iso8601, direction: "newer")

    assert_response :success
    assert_select ".calendar-month-marker", text: "March"
    assert_select ".calendar-day", text: /^\s*March\s*1\s*$/m
  end

  test "year view shows every month as a row with all its dates" do
    travel_to Date.new(2026, 9, 28) do
      get calendar_year_url

      assert_response :success
      assert_select ".year-month", count: 12
      assert_select ".year-month--len-31", count: 7
      assert_select ".year-month--len-30", count: 4
      assert_select ".year-month--len-28", count: 1

      assert_select ".year-month[aria-label=?]", "February 2026" do
        assert_select ".year-day", count: 28
        assert_select ".year-day__number", text: "28"
      end

      assert_select ".year-month[aria-label=?]", "October 2026" do
        assert_select ".year-day", count: 31
      end
    end
  end

  test "year view marks today with the porcelain tile" do
    travel_to Date.new(2026, 9, 28) do
      get calendar_year_url

      assert_select ".year-day--today", count: 1
      assert_select ".year-month[aria-label=?]", "September 2026" do
        assert_select ".year-day--today .year-day__number", text: "28"
      end
    end
  end

  test "year view accepts an explicit year" do
    get calendar_year_url(year: 2030)

    assert_response :success
    assert_select ".year-sheet__title", text: "2030"
  end

  test "year view rejects an invalid year" do
    get calendar_year_url(year: "not-a-year")

    assert_response :bad_request
  end

  test "year view rejects an out-of-range year" do
    get calendar_year_url(year: 9999)

    assert_response :bad_request
  end
end
