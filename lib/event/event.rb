module Event
  class Event
    attr_accessor :resource

    def initialize(resource)
      self.resource = resource
      resource.add_metadata(event_object: self)
    end

    def address
      page['address']
    end

    def location
      page['location']
    end

    def date
      page['event-date']
    end

    def title
      page['title']
    end

    def page
      metadata[:page]
    end

    def metadata
      resource.metadata
    end

    def app
      resource.app
    end

    def render_partial
      app.render_template(resource.source_file, {}, layout: false)
    end

    def ==(other)
      resource == other.resource
    end
  end
end
