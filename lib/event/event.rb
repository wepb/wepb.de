module Event
  class Event
    attr_accessor :resource

    def initialize(resource)
      self.resource = resource
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
  end
end
