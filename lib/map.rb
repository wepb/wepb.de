require 'geocoder'
require 'digest'
require 'net/http'
require 'erb'

module MapHelpers
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

  def render_map(address, location)
    result = geocode(address)
    options = {
      lat: result.latitude,
      lon: result.longitude,
      mlat0: result.latitude + 0.00020,
      mlon0: result.longitude
    }
    image = get_map(DEFAULT_OPTIONS.dup.merge(options))

    %(<div class="map">
        #{image_tag image}
        <span class="map-links">
          <a href="http://www.openstreetmap.org/?mlat=#{result.latitude}&amp;mlon=#{result.longitude}&amp;zoom=16">Openstreetmap</a>
          <a href="http://maps.google.com/maps?q=#{ERB::Util.url_encode("#{location}, #{address}")}&amp;ll=#{result.latitude},#{result.longitude}&amp;t=m&amp;z=16">Google Maps</a>
        </span>
        <span class="attribution">
          &copy; <a href="http://www.openstreetmap.org">OpenStreetMap</a> contributors,
          <a href="http://www.openstreetmap.org/copyright">Lizenz</a>
        </span>
      </div>)
  end

  def get_map(options)
    params = options.map { |key, value| "#{key}=#{value}" }.join("&")
    src = "/StaticMap/?#{params}"

    maps_dir = File.join(output_images_dir, "maps")
    image_file = Digest::SHA1.hexdigest(src) + ".png"
    image_path = File.join(maps_dir, image_file)
    unless File.exist?(image_path)
      FileUtils.mkdir_p(maps_dir)
      Net::HTTP.start("ojw.dev.openstreetmap.org") do |http|
        resp = http.get(src)
        open(image_path, "wb") do |file|
          file.write(resp.body)
        end
      end
    end

    "maps/#{image_file}"
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

  def output_images_dir
    File.join(build? ? build_dir : source, images_dir)
  end
end

