require 'fuzzystringmatch'
require 'open-uri'
class Crawl2Controller < ApplicationController

    LIMIT = 100
    START_BASE_NUM = 79999991

    def self.run_tj(start, count, condition)
        @songs = []
        if condition == 0
            #
        else
            song_tjnum = start - 1
            i = 0
            count_origin = count
            loop do
                song_tjnum += 1
                count -= 1
                puts "\n\n\t\tNow SONG tjnum : #{song_tjnum}, #{count} LEAVES"
                unless Song.where(song_tjnum: song_tjnum).take.nil?
                    next
                end

                puts "\t\tAND START [#{count_origin - count}/#{count_origin}] SOON."
                song = Crawl2Controller.parse_and_save_tj(song_tjnum)
                if song != false
                    @songs << song.id
                    i += 1
                end

                break if count <= 0
            end
        end
    end

    def self.parse_and_save_tj(song_tjnum)
        html_doc    = Nokogiri::HTML(Net::HTTP.get(URI("http://www.tjmedia.co.kr/tjsong/song_search_list.asp?strType=16&strText=#{song_tjnum}&strCond=0&strSize01=100&strSize02=15&strSize03=15&strSize04=15&strSize05=15")))
        a_song      = "div#BoardType1//table.board_type1//tbody//tr:nth-child(2)"
        song_info    = html_doc.css(a_song)

        aa = html_doc.css(a_song + "//td:nth-child(1)").inner_html.gsub('</span>','').gsub('<span','').gsub('class="txt">','').gsub(' ','')
        # puts "\n\n\t\t#{aa}\n\n"
        if aa != song_tjnum.to_i.to_s
            puts "\t\t#{song_tjnum} is NOT FOUND"
            return false
        end
        @song_tjnum  = html_doc.css(a_song + "//span.txt").inner_html.to_i
        @song_title  = html_doc.css(a_song + "//td.left").inner_html.to_s
        @artist_name = html_doc.css(a_song + "//td:nth-child(3)").inner_html.to_s
        @writer      = html_doc.css(a_song + "//td:nth-child(4)").inner_html.to_s
        @composer    = html_doc.css(a_song + "//td:nth-child(5)").inner_html.to_s
        
        html_doc2   = Nokogiri::HTML(Net::HTTP.get(URI("http://www.ziller.co.kr/singingroom/gasa_pop_view.jsp?pro=#{song_tjnum}")))
        lyrics_doc  = html_doc2.css('body')

        @shits = []
        4.times do |t|
            @shits << "<br>"
            if lyrics_doc.to_a.first.elements.first(t+1).last.nil?
                @shits << "<br>SORRY...<br><br>The lyric was not uploaded yet.<br>"
            else
                lyrics_doc.to_a.first.elements.first(t+1).last.children.to_a.each do |s| 
                    if s.text.length != 0
                        str = s.text
                    else
                        str = "<br>" 
                    end
                    @shits << str
                end
            end
        end
        @shits.shift

        @lyrics = @shits.join

        song = Song.where(song_tjnum: song_tjnum).take
        if song.nil?
            song = Song.new
        end
        
        song.song_tjnum     = @song_tjnum
        song.title          = @song_title
        song.artist_name    = @artist_name
        song.writer         = @writer
        song.composer       = @composer
        song.lyrics         = @lyrics
        song.save

        return song

        # => DEBUGERS//
         puts "\n\n\tsong_info   : #{song_info}\n\n"
         puts "\t\t song_tjnum   : #{@song_tjnum}"
         puts "\t\t song_title   : #{@song_title}"
         puts "\t\t artist_name  : #{@artist_name}"
         puts "\t\t writer       : #{@writer}"
         puts "\t\t composer     : #{@composer}"
         puts "\t\t lyrics       : #{@lyrics}\n\n"
         puts "\t\t song         : #{song}\n\n"
    end
    
    def index
        @songs = Song.all
        render layout: false
    end
end
