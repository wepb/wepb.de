require 'geocoder'
require 'digest'
require 'net/http'
require 'pp'

module Jekyll
  class MapTag < Liquid::Tag
    DEFAULT_OPTIONS = {
        show: 1,
        z: 16,
        w: 900,
        h: 500,
        layer: 'mapnik',
        fmt: 'png',
        att: 'none',
        mico0: 18485
    }

    def initialize(tag_name, text, tokens)
      super
    end

    def render(context)
      address = context["page"]["address"]
      result = geocode(address)
      options = {
        lat: result.latitude,
        lon: result.longitude,
        mlat0: result.latitude + 0.00020,
        mlon0: result.longitude
      }
      image = get_map(DEFAULT_OPTIONS.dup.merge(options), context["site"]["destination"])
      context["site"]["keep_files"] << "images"

      %(<div class="map">
          <img src="#{image}" alt="" />
          <span class="attribution">
            &copy; <a href="http://www.openstreetmap.org">OpenStreetMap</a> contributors,
            <a href="http://www.openstreetmap.org/copyright">Lizenz</a>
          </span>
        </div>)
    end

    def get_map(options, destination)
      params = options.map { |key, value| "#{key}=#{value}" }.join("&")
      src = "/StaticMap/?#{params}"

      image_dir = File.join(destination, "images/maps")
      image_file = Digest::SHA1.hexdigest(src) + ".png"
      image_path = File.join(image_dir, image_file)
      unless File.exist?(image_path)
        FileUtils.mkdir_p(image_dir)
        Net::HTTP.start("ojw.dev.openstreetmap.org") do |http|
          resp = http.get(src)
          open(image_path, "wb") do |file|
            file.write(resp.body)
          end
        end
      end

      "images/maps/#{image_file}"
    end

    def geocode(address)
      @@geocode_cache ||= {}
      result = @@geocode_cache[address]
      unless result
        puts "Performing geocoder lookup for #{address}..."
        result = Geocoder.search(address).first
        @@geocode_cache[address] = result
      end

      result
    end
  end
end

Liquid::Template.register_tag('map', Jekyll::MapTag)
