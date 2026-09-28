module CalendarHelper
  MOON_SVGS = {
    new: '<circle cx="12" cy="12" r="9" fill="currentColor" stroke="none"/>',
    full: '<circle cx="12" cy="12" r="9" fill="white"/>'
  }.freeze

  def moon_svg(phase)
    tag.svg(viewbox: "0 0 24 24", fill: "none", stroke: "currentColor", "stroke-width": "1.5",
            "stroke-linecap": "round", "stroke-linejoin": "round", class: "moon moon--#{phase}",
            "aria-hidden": "true") { MOON_SVGS.fetch(phase).html_safe }
  end
end
