require "test_helper"

class MoonPhaseTest < ActiveSupport::TestCase
  test "finds the new moon on a known date" do
    # New moon January 11, 2024 (11:57 UTC)
    phases = MoonPhase.for_date_range(Date.new(2024, 1, 9), Date.new(2024, 1, 13))

    assert_equal :new, phases[Date.new(2024, 1, 11)]
  end

  test "finds the new and full moons of a cycle" do
    # Cycle phases January 2024: new Jan 11, full Jan 25 (mean-formula drift is up to one day)
    phases = MoonPhase.for_date_range(Date.new(2024, 1, 10), Date.new(2024, 2, 4))

    assert_equal :new, phases[Date.new(2024, 1, 11)]

    assert_includes [ :full, nil ], phases[Date.new(2024, 1, 25)]
    assert_includes [ :full, nil ], phases[Date.new(2024, 1, 26)]
    assert_equal 1, phases.count { |_, phase| phase == :full }
  end

  test "only returns new and full phases" do
    phases = MoonPhase.for_date_range(Date.new(2030, 1, 1), Date.new(2030, 12, 31))

    assert phases.values.all? { |phase| [ :new, :full ].include?(phase) }
  end

  test "returns nothing when no phase falls in the range" do
    phases = MoonPhase.for_date_range(Date.new(2024, 1, 12), Date.new(2024, 1, 13))

    assert_empty phases
  end

  test "handles a range crossing years" do
    # Full moon December 27, 2023 (00:33 UTC)
    phases = MoonPhase.for_date_range(Date.new(2023, 12, 26), Date.new(2024, 1, 1))

    assert_equal :full, phases[Date.new(2023, 12, 27)]
  end

  test "no two phases land on the same local date" do
    phases = MoonPhase.for_date_range(Date.new(2030, 1, 1), Date.new(2030, 12, 31))

    assert_equal phases.keys.size, phases.values.size
  end
end
