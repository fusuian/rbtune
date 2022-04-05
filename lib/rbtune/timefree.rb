require "rbtune/radiko_premium"
require "date"
require "open-uri"
require "nokogiri"

class Time
	def timefree
		strftime "%Y%m%d%H%M%S"
	end
end


class TimeFree < RadikoPremium
	def self.stations
		[]
	end

	def record(filename, starttime, endtime)
		from = starttime.timefree
		to   = endtime.timefree
		# pp [@channel, from, to]
		uri = channel_to_uri from, to
		player = create_player uri
		dt = datetime starttime
		recfile = make_recfile filename, dt
		stdout, stderr, status = player.rec recfile, nil
		case stderr
		when /400 Bad Request/
			raise HTTPBadRequestException
		when /403 Forbidden/
			raise HTTPForbiddenException
		end
	end

	def channel_to_uri(from, to)
		%Q(https://radiko.jp/v2/api/ts/playlist.m3u8?l=15&station_id=#{@channel}&ft=#{from}&to=#{to})
	end

  class Program
    attr_reader :title, :from, :to, :performer, :tags
    def initialize(title, from, to, performer, tags)
      @title, @performer = [title, performer].map {|a| a.to_s }
      @from, @to = [from, to].map {|a| Program::strtotime(a.to_s) }
      @tags = tags.map {|a| a.to_s }
    end

    def include?(str)
      @title.include?(str) or
        @performer.include?(str) or
          @tags.map {|s| s.include?(str) }.any?
    end

    def self.strtotime(str)
      year, mon, day, hour, min, sec = str.scan(/^(.{4})(.{2})(.{2})(.{2})(.{2})(.{2})/)[0]
      Time.local(year, mon, day, hour, min, sec)
    end

    def self.fetch(channel)
      uri = "http://radiko.jp/v3/program/station/weekly/#{channel}.xml"
      str = OpenURI.open_uri(uri).read
      doc = Nokogiri::XML(str)
      # pp doc
      # pp doc.xpath('//date').map {|date| date.text}
      @@progs = doc.xpath('//prog').map do |prog|
        title = prog.xpath('title').text
        from, to = [prog.attribute('ft'), prog.attribute('to')]
        performer = prog.xpath('pfm').text
        tags = prog.xpath('tag/item/name').map {|name| name.text}
        Program.new(title, from, to, performer, tags)
      end
    end

    def self.timefree(progs, now=Time.now)
      progs.select { |prog| prog.from < now }
    end

    def self.search(progs, keyword)
      progs.select do |prog|
        prog.include? keyword
      end
    end
  end
end
