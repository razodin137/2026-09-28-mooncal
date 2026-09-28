# Calculates the new and full moon phases that fall within a date range,
# using the mean synodic month from a known epoch.
class MoonPhase
  PHASES = [ :new, :full ].freeze

  SYNODIC_MONTH = 29.530588861.days
  PHASE_INTERVAL = SYNODIC_MONTH / 2
  EPOCH_NEW_MOON = Time.utc(2000, 1, 6, 18, 14)

  def self.for_date_range(start_date, end_date)
    new(start_date, end_date).phases
  end

  attr_reader :start_date, :end_date

  def initialize(start_date, end_date)
    @start_date = start_date
    @end_date = end_date
  end

  # Returns a hash mapping dates within the range to the phase falling on them.
  def phases
    range = (start_date..end_date)
    phase_instants.each_with_object({}) { |(instant, phase), phases|
      date = instant.getlocal.to_date
      phases[date] = phase if range.cover?(date)
    }
  end

  private
    def phase_instants
      first_k = ((start_date.beginning_of_day - EPOCH_NEW_MOON) / PHASE_INTERVAL).ceil
      last_k = ((end_date.end_of_day - EPOCH_NEW_MOON) / PHASE_INTERVAL).floor
      first_k.upto(last_k).filter_map { |k|
        [ EPOCH_NEW_MOON + (k * PHASE_INTERVAL), PHASES[k.modulo(2)] ]
      }
    end
end
