class CalendarController < ApplicationController
  WEEKS_PER_BATCH = 5

  def show
    @weeks = weeks_from(Date.current)
    @phases = MoonPhase.for_date_range(weeks_bounds.first, weeks_bounds.last)
  end

  def year
    year = params[:year] ? Integer(params[:year], 10) : Date.current.year
    raise ActionController::BadRequest, "year out of range" unless (1900..3000).cover?(year)

    start_date = Date.new(year, 1, 1)
    end_date = Date.new(year, 12, 31)
    @year = year
    @months = (start_date..end_date).group_by(&:month).values
    @phases = MoonPhase.for_date_range(start_date, end_date)
  rescue ArgumentError, TypeError
    raise ActionController::BadRequest, "invalid year"
  end

  def weeks
    anchor = Date.parse(params.require(:date))
    direction = params.require(:direction)

    days = case direction
    when "newer" then newer_batch_days(anchor)
    else raise ActionController::BadRequest, "unknown direction: #{direction}"
    end

    @weeks = days.group_by { |day| day.beginning_of_week(:sunday) }.values
    @phases = MoonPhase.for_date_range(days.first, days.last)
    render partial: "calendar/weeks", locals: { weeks: @weeks, phases: @phases }
  rescue ArgumentError, TypeError
    raise ActionController::BadRequest, "invalid anchor"
  end

  private
    def newer_batch_days(anchor)
      first_day = anchor.beginning_of_week(:sunday) + 7
      (first_day..(first_day + 34.days)).to_a
    end

    def weeks_from(date)
      start = date.beginning_of_week(:sunday)
      ((start..(start + 4.weeks)).step(7)).map { |week_start|
        (week_start..(week_start + 6.days)).to_a
      }
    end

    def weeks_bounds
      [ @weeks.first.first, @weeks.last.last ]
    end
end
