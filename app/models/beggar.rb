require "open-uri"

class Beggar < ApplicationRecord
  def beg
    parser = JSON.parse(self.parser)
    doc = Nokogiri::HTML(URI.parse(site).open)
    ips = doc.css(parser["ip"])
    ports = doc.css(parser["port"])
    ips.map.with_index do |ip, idx|
      ip.text.strip + ":" + ports[idx].text.strip
    end
  end
end
