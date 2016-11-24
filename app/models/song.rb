class Song < ActiveRecord::Base
    belongs_to :album
    belongs_to :singer
    belongs_to :team

    def self.crawl(num)
        s = Song.new
        s.song_num = num
        return s.crawl_song
    end
    
    def self.need_crawl
        self.where(song_num: nil).where(jacket: nil) #.where.not(jacket: "Error::ThisMusickCanNotFind") #.where(album_id: nil)
    end

    def self.ok
        return self.where.not(song_num: nil).where.not(song_tjnum: nil)
    end
    
    def self.tj_ok
        return self.where.not(song_tjnum: nil).where.not(song_tjnum: 0).where.not(jacket: "http:#").where.not(jacket: "Error::ThisMusickCanNotFind").where.not(album_id: nil)
    end

    # 입력되지 않은 노래를 검색결과에 띄워줄 때, 중복크롤로 인해 깨진 노래가 함께 뜨지 않도록 거르는 메서드.
    def self.no_crash
        return self.where.not("title LIKE ?", "%<img class=%")
    end

    def self.popular_month
        result = DailyTjPopularRank.month.all.map{|song| self.find(song.song_id)}
        return result
    end

    def self.empty_tj
        return Song.where(song_tjnum: nil)
    end
    
    def self.empty_tj
        return Song.where(song_tjnum: nil)
    end
    
    # 크롤링이 전부 종료된 이후의 데이터에 대하여 jacke IMG를 크기별로 리사이징 해서 저장합니다.
    # return: "SUCCESS"
    def self.jacket_resizing(size)
        song = Song.tj_ok.all
        song.each do |s|
            jacket = s.jacket
            if size == "all"
                next if jacket.nil?
                s.jacket_resizing("nil")
            else
                if size == "middle"
                    s.jacket_middle = jacket.chomp("600x600.JPG") + "200x200.JPG" if s.jacket_middle == nil || s.jacket_middle.length < 20
                elsif size == "small"
                    s.jacket_small = jacket.chomp("600x600.JPG") + "100x100.JPG" if s.jacket_small == nil || s.jacket_middle.length < 20
                end
            end
            s.save
        end
    end

    def jacket_resizing(sth)
        jacket = self.jacket
        s = self
        return false if jacket.nil?
        if jacket.last(7).first(3).to_i == 600
            s.jacket_middle = jacket.chomp("600x600.JPG") + "200x200.JPG" #if s.jacket_middle == nil || s.jacket_middle.length < 20
            s.jacket_small = jacket.chomp("600x600.JPG") + "100x100.JPG" #if s.jacket_small == nil || s.jacket_middle.length < 20
        else
            s.jacket_middle = "http://52.78.160.188/json/img_resize/#{s.id}?size=200"
            s.jacket_small = "http://52.78.160.188/json/img_resize/#{s.id}?size=100"
        end
        s.save
        return s
    end
    
    def artist
        if self.singer_id != nil
            return Singer.find(self.singer_id)
        elsif self.team_id != nil
            return Team.find(self.team_id)
        end
        return nil
    end

    def fix
        s = crawl_song
        puts self.title
        if s == false
            puts "실패!"
        else
            puts "성공!"
        end
    end
    
    def fix2
        s = youtube
        puts self.title
        if s == false
            puts "실패!"
        else
            print s
            puts "성공!"
        end
    end
    
    def crawl_song
        num = self.song_num
        puts "song_num = " + self.song_num.to_s
        
        # GET 타겟 문서
        html_doc = CrawlController.load_page(num, "song_number")
        puts "\tGET target songs html_doc ~> OK" if html_doc != false
        
        # GET 노래 제목, 장르1, 장르2, 재생시간, 가사, 아티스트 번호, 앨범 번호
        @song_title, @song_genre1, @song_genre2, @runtime, @lyrics, @artist_num, @album_num, @jacket = CrawlController.parser_song_origin(html_doc)
        return false if @song_title.length < 1
        puts "\tPARSE target songs info ~> OK" unless @song_title.length < 1

        # SET Loop Break (wrong condition)
        validater = []
        validater = CrawlController.skip_condition()
        validater.each do |condition|
            eval("return false if @#{condition[0]} == \"#{condition[1].to_s}\"")
        end
        
        # IF album_num has nil, then SOMETHING need modify
        # GET 수정된 장르1, 장르2, 아티스트 번호, 앨범 번호, 재생시간
        if @album_num.nil?
            guess_error = html_doc.css("div#body-content//div.info-zone//ul.info-data//li//span.value").to_s.split('</span>')
            @song_genre1, @song_genre2, @artist_num, @album_num, @runtime = CrawlController.parser_modified(guess_error)
        end

        # 루프가 스킵 되지 않았다면 본격적으로 레코드에 기록하고 저장.
        song = self
        #song = Song.where(song_num: num).take
        #song = Song.new if song.nil?
        #song.title      = @song_title       ## title(제목)
        song.genre1     = @song_genre1      ## genre1(장르1)
        song.genre2     = @song_genre2      ## genre2(장르2)
        song.runtime    = @runtime          ## runtime(재생시간)
        if song.lyrics == nil
            song.lyrics = @lyrics           ## lyrics(가사) %% 주 의 %% 가사는 뷰에서 사용할때 <pre><%= @lyrics.html_safe %></pre> 이렇게 출력해야함!
        end
        song.jacket     = @jacket           ## jacket(자켓사진)         # 음원 정보(참조추출)
        
        artist = CrawlController.crawl_artist(@artist_num)
        if artist.class == Singer
            song.singer_id  = artist.id     ## artist_num(아티스트 번호) case 아티스트가 솔로
        elsif artist.class == Team
            song.team_id    = artist.id     ## artist_num(아티스트 번호) case 아티스트가 그룹
        end
        song.save
        # They Can't be Crawl in Ginnie
        #    song.songwriter = html_doc.css("---div#body-content//div.lyrics-area//div.tit-box//pre---").inner_html.to_s        ## songwriter(작사)
        #    song.composer   = html_doc.css("---div#body-content//div.lyrics-area//div.tit-box//pre---").inner_html.to_s        ## composer(작곡)
        
        album_id, trash = CrawlController.crawl_album(@album_num, @artist_num)
        unless album_id == false
            song.album_id   = album_id  ## album_id(앨범아이디)     # 앨범테이블 릴레이션
        end
        # song.song_tjnum = nil         ## song_tjnum(노래방번호 :: 나중에 따로 받아야 할듯)    # 음원 정보(고유값)
        song.song_num = num             ## song_num(지니뮤직 고뮤번호)                          # 음원 정보(고유값)
        
        # SAVE Song

        song.save
       
        # try = 0; success = 0;
        # tj_song, try, success = CrawlController.tj_linker(song, try, success)
        # numbertj = nil
        # if tj_song != false 
        #     if tj_song[0] != nil
        #         numbertj = tj_song[0]
        #     end
        # end
        
        # song.song_tjnum  = numbertj
        # song.save

        return song.jacket_resizing("a")
    end
    
    def self.match_TJ
        whole_count = Song.count
        origin_unmatched_count = Song.empty_tj.count
        
        filled_song = []
        i = 0
        pop = 0
        Song.empty_tj.each do |s|
            # 5개만 테스트
            break if i == 50
            tj_song, i, pop = CrawlController.tj_linker(s, i, pop)
            next if tj_song.count == 0
            if tj_song.count != 0 && tj_song != false
                s.song_tjnum = tj_song[0]
                s.save
                filled_song << s
            end
        end
        puts "총 #{whole_count}곡.\n\n 입력이 되지 않은 #{origin_unmatched_count}곡 중 #{pop}곡을 찾아서 추가했음!"
        
        return filled_song.map{|e| e.id}
    end

    def crawl_start_at_artist
        # song_num를 받는다
        num = self.song_num
        
        # 지니뮤직의 song 페이지에 접근해 아티스트번호와 앨범번호를 가져온다.
        html_doc = CrawlController.load_page(num, "song_number")
        @song_title, @song_genre1, @song_genre2, @runtime, @lyrics, artist_num, album_num = CrawlController.parser_song_origin(html_doc)
        puts "<<최초 로드>> artist_num: #{artist_num}, album_num: #{album_num}"
        
        if @album_num.nil?
            guess_error = html_doc.css("div#body-content//div.info-zone//ul.info-data//li//span.value").to_s.split('</span>')
            @song_genre1, @song_genre2, artist_num, album_num, @runtime = CrawlController.parser_modified(guess_error)
            puts "<<수정 로드>> artist_num: #{artist_num}, album_num: #{album_num}"
        end
        
        # artist 페이지에 접근해 정보를 받아오고 저장
        artist = CrawlController.crawl_artist(artist_num)
        # album 페이지에 접근해 정보를 받아오고 저장
        album_id, @jacket = CrawlController.crawl_album(album_num, artist_num)
        
        # Song 에 아티스트 및 앨범 저장
        self.album_id = album_id
        if artist.class == Team
            self.team_id = artist.id
        elsif artist.class == Singer
            self.singer_id = artist.id
        end
        # self.jacket = @jacket
        self.save
        
        puts self
    end
end
