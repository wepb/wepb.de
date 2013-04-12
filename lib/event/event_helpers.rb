require 'lib/event/event'

module Event
  module EventHelpers
    def event_resources
      sitemap.resources.select { |r| r.path.start_with?("events/") }
    end

    def events
      event_resources.map { |r| wrap_resource(r) }.sort_by(&:date).reverse
    end

    def next_event
      # TODO: check event dates
      events.first
    end

    def past_events
      events - [next_event]
    end

    def wrap_resource(resource)
      resource.metadata[:event_object] || Event.new(resource)
    end
  end
end
