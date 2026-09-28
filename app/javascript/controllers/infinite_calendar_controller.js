import { Controller } from "@hotwired/stimulus"

const LOOKAHEAD = 400
const MAX_BATCHES_PER_LOAD = 20

export default class extends Controller {
  static targets = [ "weeks", "bottomSentinel" ]

  connect() {
    this.loading = false
    this.newestDay = this.weeksTarget.querySelector(".calendar-week:last-child")?.dataset.endDate

    this.bottomObserver = new IntersectionObserver((entries) => this.handleIntersect(entries), { rootMargin: `${LOOKAHEAD}px 0px` })
    this.bottomObserver.observe(this.bottomSentinelTarget)
    this.loadNewer()
  }

  disconnect() {
    this.bottomObserver?.disconnect()
  }

  handleIntersect(entries) {
    if (!entries.some((entry) => entry.isIntersecting)) return

    this.loadNewer()
  }

  async loadNewer() {
    if (this.loading) return
    this.loading = true

    try {
      // The observer only fires on transitions, and appending one batch is not
      // always enough to push the sentinel out of its lookahead zone. Keep
      // loading until the sentinel actually leaves the zone so the observer can
      // re-fire on the next scroll.
      for (let i = 0; i < MAX_BATCHES_PER_LOAD; i++) {
        if (!this.sentinelInLookahead()) return

        const anchor = this.newestDay
        if (!anchor) return

        const response = await fetch(`/calendar/weeks?date=${anchor}&direction=newer`, {
          headers: { "Accept": "text/html, application/xhtml+xml" }
        })
        if (!response.ok) return

        const html = await response.text()
        const template = document.createElement("template")
        template.innerHTML = html

        const weeks = template.content.querySelectorAll(".calendar-week")
        if (weeks.length == 0) return

        this.weeksTarget.append(...weeks)
        this.newestDay = weeks[weeks.length - 1].dataset.endDate
      }
    } finally {
      this.loading = false
    }
  }

  // Mirrors the observer's intersection test: the sentinel is in the zone when
  // it overlaps the viewport extended by the rootMargin lookahead.
  sentinelInLookahead() {
    const rect = this.bottomSentinelTarget.getBoundingClientRect()
    return rect.bottom > 0 && rect.top < window.innerHeight + LOOKAHEAD
  }
}