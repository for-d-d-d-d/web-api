class Crawler
    
    def foo
        puts "\n\n\n\tfoo\n\n\n\n"
        return "\treturned!!"
    end
    
### TJ Crawling Flow
    
    # Step 1. GET target page ~> html_doc
    def load_page(uri) # searchText, type
        Nokogiri::HTML(Net::HTTP.get(URI(uri)))
    end
    
    # Step 2. Seek target song in html doc ~> a_song 
    # // 그 중에 노래 하나를 찾음.
    def pick_one
    end
    
    # Step 3. Valid confirmation Seek song with Target song ~> true 
    # // 찾은 노래가 타겟 노래와 일치하는지 확인.
    
        # Step 3.1
        # // tj사이트에서 tjnum으로 검색결과가 여러개일때 맞는애 찾아주는 함수.
        def search_correct(html_doc, song_tjnum, size)
        end
    
    # Step 4. Get song's more detail info ~> @song_tjnum, @song_title, @artist_num, @writer, @composer
    # // 노래의 정보들을 추출.
    def parsing_info
    end
    
    # Step 5. 
    # // 기존에 이미 긁어온 노래인지 확인.
    def set_song_instance(song_tjnum)
        song = Song.where(song_tjnum: song_tjnum).take
        Console.put("/* song */", song)
        if song.nil?
            song = Song.new
        end
        return song
    end
    
    # Step 6. 
    # // 노래 정보들을 저장.
    def set_song_attribute(song, attrs)
        Console.put("attrs", attrs)
        song.song_tjnum     = attrs[:song_tjnum]
        song.title          = attrs[:title]
        song.artist_name    = attrs[:artist_name]
        song.writer         = attrs[:writer]
        song.composer       = attrs[:composer]
        
        return song
    end
    
    def save(song)
        song.save
        Console.put("/* saved song's id */", Song.where(id: song.id).take.id)
        
        return song.id
    end
    
    
    
### Genie Crawling Flow
    
    # Step 1. Get target page ~> html_doc
    
    # Step 2. GET 노래 정보들을 추출. 노래 제목, 장르1, 장르2, 재생시간, 가사, 아티스트 번호, 앨범 번호
    
    # Step 3. Valid wrong condition
    # // 노래를 긁어오지 않는 경우를 정의.
    
        # Step 3.1
        # // If album_num has nil, then SOMETHING need modify
        
        # Step 3.2
        # // GET 노래 정보들을 재추출. 수정된 장르1, 장르2, 아티스트 번호, 앨범 번호, 재생시간
        
    # Step 4. 노래 정보들을 저장
    # // song 객체 column에만 채워두고 함수 종료시 save.
    
        # Step 4.1 아티스트 크롤링 & 저장. ~> 저장된 아티스트의 레코드 id
        
            # Step 4.1.1 아티스트 페이지 가져오기
            
            # Step 4.1.2 아티스트 종류(솔로/그룹) 구분
            
                # Step 4.1.2.1 솔로시 크롤링 & 저장
                
                # Step 4.1.2.2 그룹시 크롤링 & 저장
                
        # Step 4.2 아티스트 종류에 따라 구분해서 song 객체 column에 채우기.
        
        # Step 4.3 song.save
        
        # Step 4.4 앨범 크롤링 & 저장. ~> 저장된 앨범의 레코드 id
        
            # Step 4.4.1 전에 저장했던 앨범인지 확인(존재하면 이하 생략하고 앨범 record id만 리턴)
            
            # Step 4.4.2 앨범 페이지 가져오기
            
            # Step 4.4.3 앨범 정보 추출. 앨범 제목, 장르1, 장르2, 제작사, 기획사, 발매일, 자켓url
            
            # Step 4.4.4 추출 실패했다면 Valid
            
            # Step 4.4.5 추출한 앨범 정보를 객체에 채우기.
            
            # Step 4.4.6 <Step 4.1> 앨범의 아티스트 크롤링
            
            # Step 4.4.7 아티스트 종류에 따라 구분해서 album 객체 column에 채우기.
            
            # Step 4.4.8 앨범 넘버 채우고 레코드 저장.
            
        # Step 4.5 앨범 크롤링 성공시 song 객체에 album 레코드 id 채우기.
        
        # Step 4.6 song.save
        
        # Step 4.7 긁어온 노래의 쟈켓 리사이징.
    
    
    
    
### Core Feature
    
    # Feature 1. TJ 일괄 크롤링(범주 설정 가능)
    
    # Feature 2. Genie 개별 크롤링
    
    # Feature 3. 매달 이달의 신곡 업데이트 크롤링(수동 + 자동)
    
    # Feature 4. 전체 '이달의 신곡' 크롤링
    
    # Feature 5. 매달 인기차트 업데이트 크롤링
    
    # Feature 6. 전체 '인기차트' 크롤링
    
    
    
### Side Feature
    
    # Side 1. 자켓 일괄 리사이징.
    
    # Side 2. 자켓 개별 리사이징.
    
    # Side 3. 또 뭐있지?
    
    
end




class Ky < Crawler
    
    # KY에만 해당되는 것?
end

class Genie < Crawler
    
    # Genie에만 해당되는 것?
end

class Melon < Crawler
    
    # Melon에만 해당되는 것?
end