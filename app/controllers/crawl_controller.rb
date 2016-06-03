class CrawlController < ApplicationController
  require 'fuzzystringmatch'

  # Method Name : load_page
  # Method Parameter : searchText=검색어
  #                    , type=찾을 곳(
  # song_title:제목으로검색
  # singer_name:가수이름으로검색
  # song_number:번호로검색
  # album_number:앨범번호로검색
  # )
  # Method Description : 검색을 하고 해당하는 테이블의 데이터 전체를 반환하게됨. 데이터를 받아 활용하기 전에 호출.
  def self.load_page(searchText, type)
    return false if searchText.nil? || type.nil?
    searchText = CGI::escape(searchText.to_s)
    puts type.to_s + " query : " + searchText

    case type
    when "song_title"
      return Nokogiri::HTML(Net::HTTP.get(URI("http://www.tjmedia.co.kr/tjsong/song_search_list.asp?strType=0&strText=#{searchText}&strCond=0&strSize01=100&strSize02=15&strSize03=15&strSize04=15&strSize05=15"))).css("table.board_type1").first.css("tbody//tr")
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

  # Method Name : tj_daily_popular
  # Method Procedure :
  # Method Description :
  def tj_daily_popular
    #-----------------------------------------------------------------------------------------------------
    # Parameter Mapping(TJ와 같은 방식으로) : 설정기간 {'언제부터' '언제까지' 기간 중에 인기 Top100 보기}
    ## 언제부터
    @syy = params[:syy]
    @smm = params[:smm]
    @sdd = params[:sdd]

    ## 언제까지
    @eyy = params[:eyy]
    @emm = params[:emm]
    @edd = params[:edd]
    #-----------------------------------------------------------------------------------------------------

    # 타겟 문서 가져오기(속칭 긁어오기 또는 크롤링)
    uri = URI("http://m.tjmedia.co.kr/tjsong/song_Popular.asp?SYY=#{@syy}&SMM=#{@smm}&SDD=#{@sdd}&EYY=#{@eyy}&EMM=#{@emm}&EDD=#{@edd}")   # 크롤러가 접속하게 될 주소.
    html_doc = Nokogiri::HTML(Net::HTTP.get(uri))   # 쉽게, {{ 주소창에 uri(주소)를 get방식으로 넣고 return받은 HTML을 전부 html_doc에 담는다 }} 라는 노코기리 문법.

    # 이후 작업은 html_doc에 담아온 HTML문서를 파싱하는 과정
    @result     = html_doc.css("table.board_type1")   # 순위 전체를 담은 테이블(표)를 잘 가져오는가.
    @result1    = html_doc.css("table.board_type1//tr:nth-child(2)")   # 1위에 해당하는 한 행을 잘 뽑아오는가. => 규칙성 확인.
    @result100  = html_doc.css("table.board_type1//tr:nth-child(101)") # 100위에 해당하는 한 행을 잘 뽑아오는가. => 원하는 크롤링 범위의 처음과 끝이 규칙을 가지고 잘 파싱됨을 확인.

    # 규칙성을 가진 한 주기(여기서는 순위별로 한개의 행)를 반복문에 넣어 전부 파싱.
    (1..100).to_a.each do |ii|
      i = ii.to_i

      # 주석은 코드리뷰를 위한 과거형 코드
      @result_0    = html_doc.css("table.board_type1//tr:nth-child(#{i+1})")    # @result   = html_doc.css("table.board_type1").to_s
      eval("@result#{i}_1 = @result_0.css(\"tr//td:nth-child(1)\").inner_html") # a_rank    = result.css("tr//td:nth-child(1)").inner_html  # a_rank = eval("@result#{i}_1")
      eval("@result#{i}_2 = @result_0.css(\"tr//td:nth-child(2)\").inner_html") # b_songNum = result.css("tr//td:nth-child(2)").inner_html  # b_songNum = eval("@result#{i}_2")
      eval("@result#{i}_3 = @result_0.css(\"tr//td:nth-child(3)\").inner_html") # c_title   = result.css("tr//td:nth-child(3)").inner_html  # c_title = eval("@result#{i}_3")
      eval("@result#{i}_4 = @result_0.css(\"tr//td:nth-child(4)\").inner_html") # d_songBy  = result.css("tr//td:nth-child(4)").inner_html  # d_songBy = eval("@result#{i}_4")
    end
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
    render text: "finished"
  end

  ############################################################################################################

  # Method Name : songs_do
  # Method Procedure :
  # Method Description : 최초 크롤러 from 지니 , 2가지 테이블을 채운다.
  def songs_do
    #-----------------------------------------------------------------------------------------------------
    # Setting( Focus.한번에 몇개 긁어올지 - 권장 20개, 장기크롤링 - 100개 )
    ## 정탐색 갯수 설정(파생탐색 및 탐색 손실은 측정하지 않음)
    # 갯수 지정 안할 시 기본값 1천개(예상 소요시간: 5분)
    how_many_songs_do_you_want = 10
    # 지정된 갯수대로 크롤링(속도: 100여개/30초, 200여개/분, 2천여개/10분)
    # how_many_songs_do_you_want = params[:id].to_i unless params[:id].nil?

    ## 언제부터
    if Song.last == nil
      @start_num = 79999991   # 예제) 82425426 번은 악동뮤지션 200% 곡의 넘버임
    else
      # @start_num = 79999991
      @start_num = Song.last.song_num + 1
    end
    # last_saved_song_count = Song.count
    @start_num = params[:start_at].to_i unless params[:start_at].nil?

    #멈춰야하는 SongNumber
    @must_break_id_limit_count = @start_num + how_many_songs_do_you_want
    #-----------------------------------------------------------------------------------------------------

    num = @start_num - 1
    loop do
      break if num >= @must_break_id_limit_count
      num += 1
      next if Song.where(song_num: num).take.present?
      next if Song.crawl(num) == false
    end

    # Start debugger
    @message = how_many_songs_do_you_want.to_s + "개 저장완료! 확인하셈!"
    # End debugger
    render layout: false
    puts "요청하신 크롤링이 종료되었습니다."
  end

  def self.crawl_artist(artist_num)
    html_doc_artist = load_page(artist_num, "artist_number")
    return false if artist_num == 0
    @is_singer = html_doc_artist.css("div#body-content//div.info-zone//li//span.value").first.to_s.gsub('<span class="value">','').gsub('</span>','')
    puts "crawl_artist called // query : " + artist_num.to_s + "is_singer = " + @is_singer
    if @is_singer == "남성/솔로" || @is_singer == "여성/솔로"
      return self.crawl_singer(html_doc_artist, artist_num)
    else
      return self.crawl_team(html_doc_artist, artist_num)
    end
  end

  def self.crawl_singer(html_doc_singer, artist_num)
    singer = Singer.new
    singer = Singer.where(artist_num: artist_num).first unless Singer.where(artist_num: artist_num).first.nil?

    singer.photo = "http:" + html_doc_singer.css("div#body-content//div.photo-zone//a")[0]['href'].to_s
    singer.name = html_doc_singer.css("div#body-content//div.info-zone//h2.name").inner_html.to_s.strip

    singer.artist_num = artist_num
    singer.save
    return singer
  end

  def self.crawl_team(html_doc_team, artist_num)
    team = Team.new
    team = Team.where(artist_num: artist_num).first unless Team.where(artist_num: artist_num).first.nil?

    team.photo = "http:" + html_doc_team.css("div#body-content//div.photo-zone//a")[0]['href'].to_s
    team.name = html_doc_team.css("div#body-content//div.info-zone//h2.name").inner_html.to_s.strip
    team.artist_num = artist_num

    team.save

    #Team에 소속된 모든 artist에 대하여 크롤링을 실행
    html_doc_team.css("div.artist-member-list//li//a").each do |t|
      artist_num2 = t.to_s.gsub('<a href="#" onclick="fnViewArtist(' , '/////').gsub('\');return false;">' , '/////').split('/////')[1].to_i
      artist = self.crawl_artist(artist_num2)
      next unless artist

      if artist.class == Singer
        st = SingerTeam.new
        st.team_id = team.id
        st.singer_id = artist.id
        st.save
      elsif artist.class == Team
        tt = TeamTeam.new
        tt.team_id = team.id
        tt.team2_id = artist.id
        tt.save
      end
    end

    return team
  end

  ############################################################################################################
  ############################################################################################################

  def gini_song_parser(html_doc)

  end

  def gini_album_parser()
  end

  ############################################################################################################
  ############################################################################################################


  ############################################################################################################

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
  def string_difference_percent(a, b)
    jarow = FuzzyStringMatch::JaroWinkler.create( :pure )
    return (jarow.getDistance( a, b ) * 100).ceil
  end

  # Method Name : tj_linker
  # Method Procedure :
  # Method Description :
  def tj_linker
    File.open "./public/log/crawler/tj_linker/log.txt", 'w+' do |f|
      i = 0
      Song.all.each do |s|
        # 5개만 테스트
        break if i == 5

        #변수를 초기화하고 load_page메소드를 이용하여 크롤링
        a = Array.new
        strText = s.title
        @songs = CrawlController.load_page(strText, "song_title")

        i += 1
        singer = Album.where(album_num: s.album_num).first.artist_name
        j = 0

        # 노래 제목과 가수 이름을 매치시켜봄.
        @songs.each do |x|
          j += 1
          next if j == 1
          title = x.css("td:nth-child(2)").inner_html.gsub('</span>','').gsub("<span class=\"txt\">",'')
          f.puts s.title + " 과 " + title + " 비교 " + string_difference_percent(s.title, title).to_s + "% 일치"
          if s.title == title # && singer == x.css("td:nth-child(3)")
            a << x.css("td:nth-child(1)").inner_html
          end
        end

        # 결과가 0개, 1개이상, 1개일때 로그출력
        if a.count == 0
          f.puts "'#{s.title} - #{singer}' 의 해당하는 노래를 찾지 못했습니다."
        elsif a.count > 1
          f.puts "'#{s.title} - #{singer}' 의 해당하는 노래를 2곡 이상 찾아냈습니다."
          a.each do |aa|
            f.puts "   SongNumber : #{aa}"
          end
        else
          f.puts "'#{s.title} - #{singer}' 의 해당하는 노래 찾아냈습니다."
          f.puts "   SongNumber : #{a[0]}"
        end
        f.puts ""
        # break
      end
    end
    render text: File.open("./public/log/crawler/tj_linker/log.txt").read
  end
end
