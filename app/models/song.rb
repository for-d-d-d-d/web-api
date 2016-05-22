class Song < ActiveRecord::Base
    belongs_to :album
    belongs_to :singer
    belongs_to :team

    def self.clip(num)
      s = Song.new
      s.song_number = num
      return s
    end

    def artist
      if !(self.singer_id.nil?)
        return Singer.where(id: self.singer_id).first
      elsif self.team_id != nil
        return Team.where(id: self.team_id).first
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

    def crawl_song
      num = self.song_num
      puts "song_num = " + self.song_num.to_s
      # 타겟 문서 가져오기(속칭 긁어오기 또는 크롤링)
      html_doc = CrawlController.load_page(num, "song_number")

      @song_title = html_doc.css("div#body-content//div.info-zone//h2.name").inner_html.to_s.strip!
      @song_ganre1 = html_doc.css("div#body-content//div.info-zone//ul.info-data//li:nth-child(3)//span.value").inner_html.to_s.split(' / ').first.to_s
      @song_ganre2 = html_doc.css("div#body-content//div.info-zone//ul.info-data//li:nth-child(3)//span.value").inner_html.to_s.split(' / ').last.to_s

      # 다음 상황에서는 루프를 스킵한다.
      # =>유형1. @song_title = "제목이 발견되지 않는다"
      return false if @song_title.length == 0
      # =>유형2. @song_ganre1 == "CCM"
      # =>유형3. @song_ganre1 == "클래식"
      # =>유형4. @song_ganre2 == "불교음악"
      # =>유형5. @song_ganre2 == "뮤직테라피"
      # =>유형6. @song_ganre2 == "뉴에이지"
      return false if @song_ganre1 == "CCM" || @song_ganre1 == "클래식" || @song_ganre2 == "불교음악" || @song_ganre2 == "뮤직테라피" || @song_ganre2 == "뉴에이지"

      # =>유형7. 앨범번호 에러시 예외처리
      guess_error = html_doc.css("div#body-content//div.info-zone//ul.info-data//li:nth-child(2)//span.value//a")[0]
      if guess_error.nil?
        error7 = true
        guess_error = html_doc.css("div#body-content//div.info-zone//ul.info-data//li//span.value").to_s.split('</span>')
        @song_ganre1 = guess_error[2].gsub('<span class="value">','').split(' / ').first.to_s
        @song_ganre2 = guess_error[2].gsub('<span class="value">','').split(' / ').last.to_s
        @artist_num = guess_error.first.gsub('<a href="#" onclick="fnGoMore(\'artistInfo\',\'' , '/////').gsub('\');return false;">' , '/////').split('/////')[1].to_i
        @album_num = guess_error.second.gsub('<a href="#" onclick="fnGoMore(\'albumInfo\',\'' , '/////').gsub('\');return false;">' , '/////').split('/////')[1].to_i
        @runtime = guess_error[3].gsub('<span class="value">','').to_s
      end

      # 루프가 스킵 되지 않았다면 본격적으로 데이터를 작성하자.
      # 임의로 때려넣은 지니넘버 주소에 노래정보 있는거 확인했으니까
      # 긁어올거 일단 다 긁어오고나서 저장하자

      ###################################
      #**      Song Table Details     **#
      song = Song.where(song_num: num).first
      song = Song.new if song.nil?
      # 음원 정보(보통)
      ## title(제목)
      song.title = @song_title
      ## ganre1(장르1)
      song.ganre1 = @song_ganre1
      ## ganre2(장르2)
      song.ganre2 = @song_ganre2
      ## runtime(재생시간)
      @runtime = html_doc.css("div#body-content//div.info-zone//ul.info-data//li:nth-child(4)//span.value").inner_html.to_s unless error7
      song.runtime = @runtime
      ## lyrics(가사) %% 주 의 %% 가사는 뷰에서 사용할때 <pre><%= @lyrics.html_safe %></pre> 이렇게 출력해야함!
      @lyrics = html_doc.css("div#body-content//div.lyrics-area//div.tit-box//pre").inner_html.to_s
      song.lyrics = @lyrics
      ## songwriter(작사)
      #@lyrics = html_doc.css("div#body-content//div.lyrics-area//div.tit-box//pre").inner_html.to_s
      #song.lyrics = @lyrics
      ## composer(작곡)
      #@lyrics = html_doc.css("div#body-content//div.lyrics-area//div.tit-box//pre").inner_html.to_s
      #song.lyrics = @lyrics

      # 음원 정보(참조)
      ## artist_num(아티스트 번호)
      @artist_num = html_doc.css("div#body-content//div.info-zone//ul.info-data//li:nth-child(1)//span.value//a")[0]['onclick'].to_s.gsub("fnGoMore('artistInfo','","").first(8) unless error7
      # song.artist_num = @artist_num
      # puts "artist_num : " + @artist_num.to_s
      artist = CrawlController.crawl_artist(@artist_num)

      if artist.class == Singer
        song.singer_id = artist.id
      elsif artist.class == Team
        song.team_id = artist.id
      end

      ## album_num(앨범 번호)
      @album_num = html_doc.css("div#body-content//div.info-zone//ul.info-data//li:nth-child(2)//span.value//a")[0]['onclick'].to_s.gsub("fnGoMore('albumInfo','","").first(8) unless error7
      # song.album_num = @album_num

      #**       Album Table Details    **#
      album = Album.where(album_num: @album_num).first
      if album.nil?
        album = Album.new
        # 타겟 문서 가져오기(속칭 긁어오기 또는 크롤링)
        html_doc_album = CrawlController.load_page(@album_num, "album_number")
        ## title(앨범제목)
        @album_title = html_doc_album.css("div#body-content//div.info-zone//h2.name").inner_html.to_s.strip
        album.title = @album_title
        ## ganre1(앨범장르1)
        @album_ganre1 = html_doc_album.css("div#body-content//div.info-zone//ul.info-data//li:nth-child(2)//span.value").inner_html.to_s.split(' / ').first.to_s
        album.ganre1 = @album_ganre1
        ## ganre2(앨범장르2)
        @album_ganre2 = html_doc_album.css("div#body-content//div.info-zone//ul.info-data//li:nth-child(2)//span.value").inner_html.to_s.split(' / ').last.to_s
        album.ganre2 = @album_ganre2
        ## publisher(발매사)
        @publisher = html_doc_album.css("div#body-content//div.info-zone//ul.info-data//li:nth-child(3)//span.value").inner_html.to_s
        album.publisher = @publisher
        ## agency(기획사)
        @agency = html_doc_album.css("div#body-content//div.info-zone//ul.info-data//li:nth-child(4)//span.value").inner_html.to_s
        album.agency = @agency
        ## released_date(발매일)
        @released_date = html_doc_album.css("div#body-content//div.info-zone//ul.info-data//li:nth-child(5)//span.value").inner_html.to_s
        album.released_date = @released_date
        ## jacket(앨범자켓 :: 이미지)
        @jacket = "http:" + html_doc_album.css("div#body-content//div.photo-zone//a")[0]['href'].to_s
        album.jacket = @jacket

        artist = CrawlController.crawl_artist(@artist_num)
        ## artist_num(아티스트 번호)
        # album.artist_num = @artist_num

        if artist.class == Singer
          album.singer_id = artist.id
        elsif artist.class == Team
          album.team_id = artist.id
        end

        ## album_num(앨범 고유번호)
        album.album_num = @album_num
        album.save #아래 앨범아이디 만들려면 먼저저장해야함.
      else
        @album_title    = album.title
        @album_ganre1   = album.ganre1
        @album_ganre2   = album.ganre2
        @publisher      = album.publisher
        @agency         = album.agency
        @released_date  = album.released_date
        @jacket         = album.jacket
        # @artist_num     = album.artist_num
        # @artist_photo   = album.artist_photo
        # @artist_name    = album.artist_name
        # @album_num      = album.album_num
      end
      #**                              **#

      # 음원 정보(참조추출)
      ## artist_photo(아티스트 사진)
      # song.artist_photo = @artist_photo
      ## jacket(자켓사진)
      song.jacket = @jacket

      # 앨범테이블 릴레이션
      ## album_id(앨범아이디)
      song.album_id = album.id
      # 음원 정보(고유값)
      ## song_tjnum(노래방번호 :: 나중에 따로 받아야 할듯)
      # song.song_tjnum = nil
      ## song_num(지니뮤직 고뮤번호)
      song.song_num = num
      #**                              **#
      ####################################

      # 다 긁었으니까 노래도 마저 저장하자
      song.save

      return song
    end
end
