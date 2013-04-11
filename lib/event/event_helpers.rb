require 'lib/event/event'

module Event
  module EventHelpers
    def event_resources
      sitemap.resources.select { |r| r.path.start_with?("events/") }
    end

    def events
      event_resources.map { |r| ::Event::Event.new(r) }.sort_by { |e| e.date }.reverse
    end

    def next_event
      # TODO: check event dates
      events.first
    end

    def past_events
      events = self.events
      events - [events.first]
    end
  end
end
