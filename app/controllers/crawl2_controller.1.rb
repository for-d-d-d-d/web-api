require 'fuzzystringmatch'
require 'open-uri'
class Crawl2Controller < ApplicationController

    LIMIT = 100
    START_BASE_NUM = 79999991

    def self.run_tj(start, count, condition)
        @songs = []
        if condition == 0
            #
        elsif condition == 10
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
                song = Crawl2Controller.parse_and_save_tj2(song_tjnum)
                if song != false
                    @songs << song.id
                    i += 1
                end

                break if count <= 0
            end
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

    # 질러넷을 포함한 한 곡 크롤링(노래방 번호, 제목, 가수이름, 작사가, 작곡가, 가사를 저장)
    def self.parse_and_save_tj(song_tjnum)
        
        # 크롤링 타겟 Page를 가져옴.
        #####/
        
        # 크롤링 타겟 Song을 a_song으로 가져옴.
        a_song      = "div#BoardType1//table.board_type1//tbody//tr:nth-child(2)"
        song_info    = html_doc.css(a_song)
        
        
        # 크롤링 타겟 Song과 a_song이 일치하는지 검증.
        aa = html_doc.css(a_song + "//td:nth-child(1)").inner_html.gsub('</span>','').gsub('<span','').gsub('class="txt">','').gsub(' ','')
        # puts "\n\n\t\t#{aa}\n\n"
        if aa != song_tjnum.to_i.to_s
            puts "\t\t#{song_tjnum} is NOT FOUND"
            return false
        end
        
        # Information 완성.
        @song_tjnum  = html_doc.css(a_song + "//span.txt").inner_html.to_i
        @song_title  = html_doc.css(a_song + "//td.left").inner_html.to_s
        @artist_name = html_doc.css(a_song + "//td:nth-child(3)").inner_html.to_s
        @writer      = html_doc.css(a_song + "//td:nth-child(4)").inner_html.to_s
        @composer    = html_doc.css(a_song + "//td:nth-child(5)").inner_html.to_s
        
        # html_doc2   = Nokogiri::HTML(Net::HTTP.get(URI("http://www.ziller.co.kr/singingroom/gasa_pop_view.jsp?pro=#{song_tjnum}")))
        # lyrics_doc  = html_doc2.css('body')

        # @shits = []
        # 4.times do |t|
        #     @shits << "<br>"
        #     if lyrics_doc.to_a.first.elements.first(t+1).last.nil?
        #         @shits << "<br>SORRY...<br><br>The lyric was not uploaded yet.<br>"
        #     else
        #         lyrics_doc.to_a.first.elements.first(t+1).last.children.to_a.each do |s| 
        #             if s.text.length != 0
        #                 str = s.text
        #             else
        #                 str = "<br>" 
        #             end
        #             @shits << str
        #         end
        #     end
        # end
        # @shits.shift
        # @lyrics     = @shits.join
        # song.lyrics = @lyrics

        song = Song.where(song_tjnum: song_tjnum).take
        if song.nil?
            song = Song.new
        end
        
        song.song_tjnum     = @song_tjnum
        song.title          = @song_title
        song.artist_name    = @artist_name
        song.writer         = @writer
        song.composer       = @composer
        
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

    # tj사이트에서 tjnum으로 검색결과가 여러개일때 맞는애 찾아주는 함수. 
    # 집어넣을것 : (긁어온 검색결과 문서, 올바른 tjnum, 검색결과 갯수)
    # 뱉어내는것 : (bolean-String status, 맞는 노래의 파싱 주소)
    def self.valid(html_doc, song_tjnum, size)
        result = ""
        a_song = ""
        size.times do |k|
            a_song  = "div#BoardType1//table.board_type1//tbody//tr:nth-child(#{k+1})"
            aa      = html_doc.css(a_song + "//td:nth-child(1)").inner_html.gsub('</span>','').gsub('<span','').gsub('class="txt">','').gsub(' ','')
            puts "\n\t\t#{aa}\n\n"
            if aa != song_tjnum.to_i.to_s
                puts "\t\t#{song_tjnum} is NOT FOUND"
                result = "false"
            else
                puts "\t\t#{song_tjnum} is FOUND !!"
                result = "true"
            end
            break if result == "true"
        end
        return result.to_s, a_song
    end
    
    # 질러넷을 포함하지 않는 한 곡 크롤링(가사 제외 / 노래방 번호, 제목, 가수이름, 작사가, 작곡가를 저장)
    def self.parse_and_save_tj2(song_tjnum)
        html_doc    = Nokogiri::HTML(Net::HTTP.get(URI("http://www.tjmedia.co.kr/tjsong/song_search_list.asp?strType=16&strText=#{song_tjnum}&strCond=0&strSize01=100&strSize02=15&strSize03=15&strSize04=15&strSize05=15")))
        puts "\n\n\t\thtml_doc.nil? #{html_doc.nil?}\n\n"

        # a_song      = "div#BoardType1//table.board_type1//tbody//tr:nth-child(5)"
        # # a_song      = "div#BoardType1//table.board_type1//tbody//tr:nth-child(14)"
        # aa = html_doc.css(a_song + "//td:nth-child(1)").inner_html.gsub('</span>','').gsub('<span','').gsub('class="txt">','').gsub(' ','')
        # puts "\n\t\t#{aa}\n\n"
        # if aa != song_tjnum.to_i.to_s
        #     puts "\t\t#{song_tjnum} is NOT FOUND"
        #     return false
        # end
        
        size    = html_doc.css("div#BoardType1//table.board_type1//tbody//tr").to_a.size
        status, a_song = Crawl2Controller.valid(html_doc, song_tjnum, size)
        if status == "false"
            return false
        end

        @song_tjnum  = html_doc.css(a_song + "//span.txt").inner_html.to_i
        @song_title  = html_doc.css(a_song + "//td.left").inner_html.to_s
        @artist_name = html_doc.css(a_song + "//td:nth-child(3)").inner_html.to_s
        @writer      = html_doc.css(a_song + "//td:nth-child(4)").inner_html.to_s
        @composer    = html_doc.css(a_song + "//td:nth-child(5)").inner_html.to_s
        # html_doc2   = Nokogiri::HTML(Net::HTTP.get(URI("http://www.ziller.co.kr/singingroom/gasa_pop_view.jsp?pro=#{song_tjnum}")))
        # puts "html_doc2.nil? ~> #{html_doc2.nil?}"
        # lyrics_doc  = html_doc2.css('body')

        # @shits = []
        # 4.times do |t|
        #     @shits << "<br>"
        #     if lyrics_doc.to_a.first.elements.first(t+1).last.nil?
        #         @shits << "<br>SORRY...<br><br>The lyric was not uploaded yet.<br>"
        #     else
        #         lyrics_doc.to_a.first.elements.first(t+1).last.children.to_a.each do |s| 
        #             if s.text.length != 0
        #                 str = s.text
        #             else
        #                 str = "<br>" 
        #             end
        #             @shits << str
        #         end
        #     end
        # end
        # @shits.shift

        # @lyrics = @shits.join
        # puts "\t\t lyrics       : #{@lyrics}\n\n"
        song = Song.where(song_tjnum: song_tjnum).take
        puts "\t\t song         : #{song}\n\n"
        if song.nil?
            song = Song.new
        end
        
        song.song_tjnum     = @song_tjnum
        song.title          = @song_title
        song.artist_name    = @artist_name
        song.writer         = @writer
        song.composer       = @composer
        # song.lyrics         = @lyrics
        song.save

        return song

        # => DEBUGERS//
        #  puts "\n\n\tsong_info   : #{song_info}\n\n"
        #  puts "\t\t song_tjnum   : #{@song_tjnum}"
        #  puts "\t\t song_title   : #{@song_title}"
        #  puts "\t\t artist_name  : #{@artist_name}"
        #  puts "\t\t writer       : #{@writer}"
        #  puts "\t\t composer     : #{@composer}"
        #  puts "\t\t lyrics       : #{@lyrics}\n\n"
        #  puts "\t\t song         : #{song}\n\n"
    end

    # 전체 이달의 신곡을 크롤링
    # res > start_month : (시작달) ex. 200701
    def self.new_song_whole(start_month)
        yyyymm_i = start_month.to_i
        loop do
            if yyyymm_i.to_s.last(2) == "13"
                yyyymm_i = (yyyymm_i - 12) + 100
            end
            Crawl2Controller.new_song_month(yyyymm_i)
            break if yyyymm_i.to_s == Time.zone.now.year.to_s + Time.zone.now.month.to_s
            yyyymm_i += 1
        end
    end

    # 매달 이달의 신곡을 갱신하는 크롤링
    # res > now_month : (이번달) ex. 201610
    def self.new_song_month(yyyymm)
        yyyymm  = yyyymm.to_s
        yyyy    = yyyymm.first(4)
        mm      = yyyymm.last(2)
        puts "\n\n\n\t\t#{yyyymm}\n\n\n"
        html_doc    = Nokogiri::HTML(Net::HTTP.get(URI("https://www.tjmedia.co.kr/tjsong/song_monthNew.asp?YY=#{yyyy}&MM=#{mm}")))
        
        raw_count = 2
        loop do
            a_song      = "div#BoardType1//table.board_type1//tbody//tr:nth-child(#{raw_count})"
            song_info   = html_doc.css(a_song)
            break if song_info.length == 0

            aa = html_doc.css(a_song + "//td:nth-child(1)").inner_html.gsub('</span>','').gsub('<span','').gsub('class="txt">','').gsub(' ','')
            
            @song_tjnum  = aa 
            @song_title  = html_doc.css(a_song + "//td.left").inner_html.to_s
            @artist_name = html_doc.css(a_song + "//td:nth-child(3)").inner_html.to_s
            @writer      = html_doc.css(a_song + "//td:nth-child(4)").inner_html.to_s
            @composer    = html_doc.css(a_song + "//td:nth-child(5)").inner_html.to_s

            song = Song.where(song_tjnum: @song_tjnum.to_i).take
            if song.nil?
                song = Song.new
                song.song_tjnum     = @song_tjnum
                song.title          = @song_title
                song.artist_name    = @artist_name
                song.writer         = @writer
                song.composer       = @composer
                song.lyrics         = @lyrics
                song.save
            else
                puts "\n\t이달의 신곡인데 왜 노래방 번호가 똑같은게 있지?\n"
                raw_count += 1
                next
            end

            #puts "#{song_info}"
            #puts "song_tjnum    =   " + @song_tjnum.to_s
            #puts "song_title    =   " + @song_title
            #puts "artist_name   =   " + @artist_name
            #puts "writer        =   " + @writer
            #puts "composer      =   " + @composer
            #puts "#{raw_count}"
            raw_count += 1
        end
        #tj_numbers = 1
        #songs = []
        #tj_numbers.each do |song_tjnum|
        #    songs << Crawl2Controller.parse_and_save_tj2(song_tjnum)
        #end
    end

    # 매달 인기차트를 갱신하는 크롤링
    # res > from = (시작월) 201610, stop = (오늘) 20161009, mode = "new" / "modify"
    def self.new_song_popular(from, stop, mode)
        if mode == "new"
            CrawlController.run_tj_popular(from, stop)
        elsif mode == "modify"
            arr = DailyTjPopularRank.where(song_id: nil).all
            arr.map{|dtpr| [dtpr.id, dtpr.song_num]}.each do |tjnum|
                song = Song.where(song_tjnum: tjnum.last).take
                song_id = nil
                unless song.nil?
                    song_id = song.id
                end
                rank_song = DailyTjPopularRank.find(tjnum.first)
                rank_song.song_id = song_id
                rank_song.save
            end
        end
    end

    def index
        @songs = Song.all
        render layout: false
    end
end
