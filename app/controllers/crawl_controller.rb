class CrawlController < ApplicationController
    require 'fuzzystringmatch'
    
    LIMIT = 100    # 개, 크롤링 하고자 하는 곡의 수 기본값
    START_BASE_NUM = 79999991 # , 노래가 존재하지 않는경우 최초에 크롤링 스타트지점
    
    # 지니뮤직 노래 (제목, 장르1, 장르2, 재생시간, 가사, 아티스트 번호, 앨범 번호) 위치
    GINNIE_SONG_TITLE       = "div#body-content//div.info-zone//h2.name"
    GINNIE_SONG_GENRE       = "div#body-content//div.info-zone//ul.info-data//li:nth-child(3)//span.value"
    GINNIE_SONG_RUNTIME     = "div#body-content//div.info-zone//ul.info-data//li:nth-child(4)//span.value"
    GINNIE_SONG_LYRICS      = "div#body-content//div.lyrics-area//div.tit-box//pre"
    GINNIE_SONG_ARTISTNUM   = "div#body-content//div.info-zone//ul.info-data//li:nth-child(1)//span.value//a"
    GINNIE_SONG_ALBUMNUM    = "div#body-content//div.info-zone//ul.info-data//li:nth-child(2)//span.value//a"
    
    # 지니뮤직 앨범 () 위치
    GINNIE_ALBUM_TITLE      = "div#body-content//div.info-zone//h2.name"
    GINNIE_ALBUM_GENRE      = "div#body-content//div.info-zone//ul.info-data//li:nth-child(2)//span.value"
    GINNIE_ALBUM_PUBLISHER  = "div#body-content//div.info-zone//ul.info-data//li:nth-child(3)//span.value"
    GINNIE_ALBUM_AGENCY     = "div#body-content//div.info-zone//ul.info-data//li:nth-child(4)//span.value"
    GINNIE_ALBUM_RELEASE    = "div#body-content//div.info-zone//ul.info-data//li:nth-child(5)//span.value"
    GINNIE_ALBUM_JACKET     = "div#body-content//div.photo-zone//a"
    
    
    # start : 시작할 노래 번호
    # ex) 82425426 번은 악동뮤지션 200% 곡의 넘버임
    def self.init()
        if Song.last == nil
            start = START_BASE_NUM
        else
            start = Song.last.song_num + 1
        end
        return LIMIT, start
    end
    
    # Method Name : load_page
    # Method Parameter : searchText=검색어
    #                    , type=찾을 곳
    #                               (
    #                                   song_title:제목으로검색
    #                                   singer_name:가수이름으로검색
    #                                   song_number:번호로검색
    #                                   album_number:앨범번호로검색
    #                               )
    # Method Description : 검색을 하고 해당하는 테이블의 데이터 전체를 반환하게됨. 데이터를 받아 활용하기 전에 호출.
    def self.load_page(searchText, type)
        return false if searchText.nil? || type.nil?
        searchText = CGI::escape(searchText.to_s)
        puts type.to_s + " query : " + searchText

        case type
        when "song_title"
            doc = Nokogiri::HTML(Net::HTTP.get(URI("http://www.tjmedia.co.kr/tjsong/song_search_list.asp?strType=0&strText=#{searchText}&strCond=0&strSize01=100&strSize02=15&strSize03=15&strSize04=15&strSize05=15")))
            if doc != nil && doc.css("table.board_type1").first != nil
                result = doc.css("table.board_type1").first.css("tbody//tr")
            else
                result = ""
            end
            return result
        when "song_number"
            return Nokogiri::HTML(Net::HTTP.get(URI("http://www.genie.co.kr/detail/songInfo?xgnm=#{searchText}")))
        when "album_number"
            return Nokogiri::HTML(Net::HTTP.get(URI("http://www.genie.co.kr/detail/albumInfo?axnm=#{searchText}")))
        when "artist_number"
            return Nokogiri::HTML(Net::HTTP.get(URI("http://www.genie.co.kr/detail/artistInfo?xxnm=#{searchText}")))
        else
            return false
        end
    end
    
    
    def run_tj_popular
        todate = Date.parse(Time.zone.now.to_s).to_s
        if params[:from] == nil || params[:from] == ""
            now_month  = todate.first(7)
        else
            now_month  = todate.first(4).to_s + "-" + params[:from].first(2).to_s
        end
        start_date = "#{now_month}-01"
        end_date = Date.parse(Time.zone.now.to_s).to_s
        
        result = "이미 이번 달은 #{end_date}까지 저장이 완료됨"
        if DailyTjPopularRank.where(eymd: end_date).take == nil
            result = tj_daily_popular(start_date, end_date)
        end
        
        render json: result
    end
    
    # Method Name : tj_daily_popular
    # Method Procedure :
    # Method Description : 인기차트(연월일 부터 ~ 연월일 까지)
    def tj_daily_popular(start_date, end_date)
        #-----------------------------------------------------------------------------------------------------
        # Parameter Mapping(TJ와 같은 방식으로) : 설정기간 {'언제부터' '언제까지' 기간 중에 인기 Top100 보기}
        ## 언제부터
        syy = start_date.first(4)
        smm = start_date.first(7).last(2)
        sdd = start_date.last(2)

        ## 언제까지
        eyy = end_date.first(4)
        emm = end_date.first(7).last(2)
        edd = end_date.last(2)
        #-----------------------------------------------------------------------------------------------------

        # 타겟 문서 가져오기(속칭 긁어오기 또는 크롤링)
        uri = URI("http://m.tjmedia.co.kr/tjsong/song_Popular.asp?SYY=#{syy}&SMM=#{smm}&SDD=#{sdd}&EYY=#{eyy}&EMM=#{emm}&EDD=#{edd}")   # 크롤러가 접속하게 될 주소.
        html_doc = Nokogiri::HTML(Net::HTTP.get(uri))   # 쉽게, {{ 주소창에 uri(주소)를 get방식으로 넣고 return받은 HTML을 전부 html_doc에 담는다 }} 라는 노코기리 문법.

        # 이후 작업은 html_doc에 담아온 HTML문서를 파싱하는 과정
        @result     = html_doc.css("table.board_type1")   # 순위 전체를 담은 테이블(표)를 잘 가져오는가.
        @result1    = html_doc.css("table.board_type1//tr:nth-child(2)")   # 1위에 해당하는 한 행을 잘 뽑아오는가. => 규칙성 확인.
        @result100  = html_doc.css("table.board_type1//tr:nth-child(101)") # 100위에 해당하는 한 행을 잘 뽑아오는가. => 원하는 크롤링 범위의 처음과 끝이 규칙을 가지고 잘 파싱됨을 확인.
        
        td_songs = []
        # 규칙성을 가진 한 주기(여기서는 순위별로 한개의 행)를 반복문에 넣어 전부 파싱.
        (1..100).to_a.each do |ii|
            i = ii.to_i

            # 주석은 코드리뷰를 위한 과거형 코드
            @result_0    = html_doc.css("table.board_type1//tr:nth-child(#{i+1})")    # @result = html_doc.css("table.board_type1").to_s
            eval("@result#{i}_1 = @result_0.css(\"tr//td:nth-child(1)\").inner_html") # rank    = result.css("tr//td:nth-child(1)").inner_html  # a_rank = eval("@result#{i}_1")
            eval("@result#{i}_2 = @result_0.css(\"tr//td:nth-child(2)\").inner_html") # songNum = result.css("tr//td:nth-child(2)").inner_html  # b_songNum = eval("@result#{i}_2")
            eval("@result#{i}_3 = @result_0.css(\"tr//td:nth-child(3)\").inner_html") # title   = result.css("tr//td:nth-child(3)").inner_html  # c_title = eval("@result#{i}_3")
            eval("@result#{i}_4 = @result_0.css(\"tr//td:nth-child(4)\").inner_html") # songBy  = result.css("tr//td:nth-child(4)").inner_html  # d_songBy = eval("@result#{i}_4")
            
            eval("@tjnum = @result#{i}_2")
            td_song = DailyTjPopularRank.new
            td_song.symd = "#{start_date}"
            td_song.eymd = "#{eyy.to_s}-#{emm.to_s}-#{edd.to_s}"
            eval("td_song.song_rank    = @result#{i}_1")
            eval("td_song.song_num     = @result#{i}_2")
            eval("td_song.song_title   = @result#{i}_3")
            eval("td_song.song_singer  = @result#{i}_4")
            
            matched_song_id = from_tj_match_db(@tjnum)
            if matched_song_id == false
                matched_song_id = nil
            end
            td_song.song_id            = matched_song_id
            td_song.save
            
            td_songs << td_song.id
        end
        
        return td_songs
    end
    
    def from_tj_match_db(tjnum)
        matched_song = Song.where(song_tjnum: tjnum).take
        return false if matched_song == nil
        
        song_id = matched_song.id
        return song_id
    end

    # Method Name : save_daily_popular
    # Method Procedure :
    # Method Description :
    def save_daily_popular
        a = DailyTjPopularRank.new
        DailyTjPopularRank.attribute_names.each do |atn|
            next if atn == "id" || atn == "created_at" || atn == "updated_at"
            eval("a.#{atn} = params[:#{atn}]")
        end
        a.save
        redirect_to :back
    end

    ############################################################################################################

    def fix_all
        Song.all.each do |s|
            s.fix
        end
        # render text: "finished"
        redirect_to :back
    end
    
    def youtube
        videos = Yt::Collections::Videos.new
        
        Song.all.each do |s|
            a = videos.where(q: "[MV] " + s.title + s.artist.name).first
            unless a.nil?
                s.youtube = a.id
            else
                s.youtube = ""
            end
            s.save
        end
        
        redirect_to :back
    end
    def run_song
        var_count = params[:count]
	var_start = params[:start_at]
        success = CrawlController.run(var_count, var_start)
        
        render json: success
    end
    # Method Name : run
    # Method Procedure :
    # Method Description : 최초 크롤러 from 지니
    def self.run(var_count, var_start)
        count, @start_num = CrawlController.init()
        count = var_count.to_i unless var_count.nil?
        @start_num = var_start.to_i unless var_start.nil?
        # last_saved_song_count = Song.count
        count_origin = count
        num = @start_num - 1
        loop do
            break if count <= 0
            num += 1
            next if Song.where(song_num: num).take.present?
            next if Song.crawl(num) == false
            count -= 1
        end
        
        puts "요청하신 크롤링이 종료되었습니다."
        return count_origin, count
    end
    
    def self.skip_condition()
        # 노래를 긁어오지 않는 경우를 정의
        validate_array = [
                ["song_title.length",    0],
                ["song_genre1",         "CCM"],
                ["song_genre1",         "클래식"],
                ["song_genre2",         "불교음악"],
                ["song_genre2",         "뮤직테라피"],
                ["song_genre2",         "뉴에이지"]
            ]
        return validate_array
    end
    
    # roll  :   HTML DOC parser 
    # desc  :   STEP1   (before validation check & ready validation Resources)
    def self.parser_song_origin(html_doc)
        song_title  = html_doc.css(GINNIE_SONG_TITLE).inner_html.to_s.strip!
        song_genre1 = html_doc.css(GINNIE_SONG_GENRE).inner_html.to_s.split(' / ').first.to_s
        song_genre2 = html_doc.css(GINNIE_SONG_GENRE).inner_html.to_s.split(' / ').last.to_s
        runtime     = html_doc.css(GINNIE_SONG_RUNTIME).inner_html.to_s
        lyrics      = html_doc.css(GINNIE_SONG_LYRICS).inner_html.to_s
        artist_num  = html_doc.css(GINNIE_SONG_ARTISTNUM)[0]['onclick'].to_s.gsub("fnGoMore('artistInfo','","").first(8)
        if html_doc.css("div#body-content//div.info-zone//ul.info-data//li:nth-child(2)//span.value//a")[0].nil?
            album_num   = nil
        else
            album_num   = html_doc.css(GINNIE_SONG_ALBUMNUM)[0]['onclick'].to_s.gsub("fnGoMore('albumInfo','","").first(8)
        end
        return song_title, song_genre1, song_genre2, runtime, lyrics, artist_num, album_num
    end
    
    # roll  :   HTML DOC modified parser 
    # desc  :   앨범번호 에러시 필요한 항목 수정처리 (after validation check)
    def self.parser_modified(html_doc)
        song_genre1 = html_doc[2].gsub('<span class="value">','').split(' / ').first.to_s
        song_genre2 = html_doc[2].gsub('<span class="value">','').split(' / ').last.to_s
        artist_num  = html_doc.first.gsub('<a href="#" onclick="fnGoMore(\'artistInfo\',\'' , '/////').gsub('\');return false;">' , '/////').split('/////')[1].to_i
        album_num   = html_doc.second.gsub('<a href="#" onclick="fnGoMore(\'albumInfo\',\'' , '/////').gsub('\');return false;">' , '/////').split('/////')[1].to_i
        runtime     = html_doc[3].gsub('<span class="value">','').to_s
        return song_genre1, song_genre2, artist_num, album_num, runtime
    end
    
    # roll  :   HTML DOC parser 
    # desc  :   Album doc parse
    def self.parser_album_origin(html_doc_album)
        album_title     = html_doc_album.css(GINNIE_ALBUM_TITLE).inner_html.to_s.strip
        album_genre1    = html_doc_album.css(GINNIE_ALBUM_GENRE).inner_html.to_s.split(' / ').first.to_s
        album_genre2    = html_doc_album.css(GINNIE_ALBUM_GENRE).inner_html.to_s.split(' / ').last.to_s
        publisher       = html_doc_album.css(GINNIE_ALBUM_PUBLISHER).inner_html.to_s
        agency          = html_doc_album.css(GINNIE_ALBUM_AGENCY).inner_html.to_s
        released_date   = html_doc_album.css(GINNIE_ALBUM_RELEASE).inner_html.to_s
        jacket          = "http:" + html_doc_album.css(GINNIE_ALBUM_JACKET)[0]['href'].to_s
        
        return album_title, album_genre1, album_genre2, publisher, agency, released_date, jacket
    end
    
    

    def self.crawl_artist(artist_num)

        if artist_num == '14958011'
            s = Singer.where(name: "Various Artist").first
            if s.nil?
                s = Singer.new
                s.name = "Various Artist"
                s.save
            end
            return s
        end

        html_doc_artist = load_page(artist_num, "artist_number")
        return false if artist_num.to_i <= 0
        @is_singer = html_doc_artist.css("div#body-content//div.info-zone//li//span.value").first.to_s.gsub('<span class="value">','').gsub('</span>','')
        puts "crawl_artist called // query : " + artist_num.to_s + " is_singer = " + @is_singer
        if @is_singer == "남성/솔로" || @is_singer == "여성/솔로"
            return self.crawl_singer(html_doc_artist, artist_num, @is_singer)
        else
            return self.crawl_team(html_doc_artist, artist_num, @is_singer)
        end
    end

    def self.crawl_singer(html_doc_singer, artist_num, typee)
        singer = Singer.new
        singer = Singer.where(artist_num: artist_num).take unless Singer.where(artist_num: artist_num).take.nil?

        singer.photo = "http:" + html_doc_singer.css("div#body-content//div.photo-zone//a")[0]['href'].to_s
        singer.name = html_doc_singer.css("div#body-content//div.info-zone//h2.name").inner_html.to_s.strip
        gender = typee.split('/').first
        if gender == "남성"
            singer.gender = 1 #남성
        elsif gender == "여성"
            singer.gender = 2 #여성
        else
            singer.gender = nil #error
        end
        singer.typee = typee.split('/').last
        singer.artist_num = artist_num
        singer.save
        return singer
    end

    def self.crawl_team(html_doc_team, artist_num, typee)
        team = Team.new
        team = Team.where(artist_num: artist_num).first unless Team.where(artist_num: artist_num).first.nil?

        team.photo = "http:" + html_doc_team.css("div#body-content//div.photo-zone//a")[0]['href'].to_s
        team.name = html_doc_team.css("div#body-content//div.info-zone//h2.name").inner_html.to_s.strip
        team.artist_num = artist_num
        gender = typee.split('/').first
        if gender == "남성"
            team.gender = 1
        elsif gender == "여성"
            team.gender = 2
        elsif gender == "혼성"
            team.gender = 4
        else
            team.gender = nil #error
        end
        team.typee = typee.split('/').last
        team.save

        #Team에 소속된 모든 artist에 대하여 크롤링을 실행
        html_doc_team.css("div.artist-member-list//li//a").each do |t|
            artist_num2 = t.to_s.gsub('<a href="#" onclick="fnViewArtist(' , '/////').gsub('\');return false;">' , '/////').split('/////')[1].to_i
            artist = self.crawl_artist(artist_num2)
            next unless artist

            if artist.class == Singer
                if SingersTeam.where(team_id: team.id, singer_id: artist.id).first.nil?
                    st = SingersTeam.new
                    st.team_id = team.id
                    st.singer_id = artist.id
                    st.save
                end
            elsif artist.class == Team
                if TeamTeam.where(team_id: team.id, team2_id: artist.id).first.nil?
                    tt = TeamTeam.new
                    tt.team_id = team.id
                    tt.team2_id = artist.id
                    tt.save
                end
            end
        end

        return team
    end

    # Method Name : songs_rematch_for_correct_album
    # Method Procedure :
    # Method Description : 노래와 앨범을 다시 제대로 매치시켜주는 함수
    def songs_rematch_for_correct_album
        @song = Song.all
        unmathed_song = Array.new

        @song.each do |song|                                                # 일단 노래를 다 돌린다.
            if Album.where(id: song.album_id).count == 0                      # 이 노래가 앨범을 못찾고있는지?
                unmathed_song << song                                           # 그럼 문제있는놈.
            else                                                              # 앨범찾으면 1차 통과.

                if Album.find(song.album_id).album_num != song.album_num        # 찾은 앨범이 안맞는 앨범인지?
                    unmathed_song << song                                         # 그럼 문제있는놈.
                end                                                             # 끝
            end
        end

        i = 1
        unmathed_song.each do |x|
            x.album_id = Album.where(album_num: x.album_num).take.id
            x.save
            i += 1
        end

        puts "#{i.to_s}개의 노래가 수정되었습니다"
    end

    # Method Name : string_difference_percent(a, b)
    # Method Procedure :
    # Method Description : a, b를 비교하여 비교정도 반환 (%)
    def self.string_difference_percent(a, b)
        jarow = FuzzyStringMatch::JaroWinkler.create( :pure )
        return (jarow.getDistance(a, b) * 100).ceil
    end

    # Method Name : tj_linker
    # Method Procedure :
    # Method Description :
    def self.tj_linker(s, i, pop)
        if s.artist == nil
            if s.singer_id != nil
                song_artist = Singer.find(s.singer_id).name
            elsif s.team_id != nil
                song_artist = Team.find(s.team_id).name
            else
                song_artist = nil
            end
        else
            song_artist = s.artist.name
        end
        #변수를 초기화하고 load_page 메소드를 이용하여 크롤링
        puts "#{s}\n\n#{song_artist} "
        strText = s.title
        if song_artist == nil
            singer = ""
        else
            singer = song_artist
        end
        @results = CrawlController.load_page(strText, "song_title")
        if @results == ""
            return false, false, false
        end
        i += 1
        winner_rate = 0
        @box = []
        puts "#{i} after box"
        # 노래 제목과 가수 이름을 매치시켜봄.
        j = 0
        @results.each do |x|
            j += 1
            puts "j = #{j}"
            tj_num  = x.css("td:nth-child(1)").inner_html
            title   = x.css("td:nth-child(2)").inner_html.gsub('</span>','').gsub("<span class=\"txt\">",'')
            artist  = x.css("td:nth-child(3)").inner_html.gsub('</span>','').gsub("<span class=\"txt\">",'')
            # puts "#{tj_num}, #{title}, #{artist} before percent"
            match_title     = CrawlController.string_difference_percent(strText, title).to_i
            match_artist    = CrawlController.string_difference_percent(singer, artist).to_i
            
            puts "#{strText}의 #{singer}와, 제목 #{match_title}%, 가수명 #{match_artist}% 일치. after percent"
            array = Array.new
            array = [tj_num, [s.title, title, match_title], [singer, artist, match_artist]]
            
            challeng_rate = match_title + match_artist
            if challeng_rate >= winner_rate
                winner_rate = challeng_rate
                @box = array
            end
            
            puts "\n\n\n\n#{i}번째 곡을 위한 탐색, #{j}번째 비교중.  \n현재곡 : #{array[1][0]}(array[1][0]),\n\n현재 최고득점 : box #{@box}\n\n\n\n"
        end
        
        if (@box[1][2].to_i + @box[2][2].to_i) >= 180
            puts "'#{s.title} - #{singer}' 의 해당하는 노래를 찾아냈습니다."
            pop += 1
            puts "\n\n\n  #{pop}번째 일치 곡 발견! : #{@box}\n\n\n"
        else
            @box = []
        end
        puts ""
        return @box, i, pop
    end

end
