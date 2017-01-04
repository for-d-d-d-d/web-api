require 'crawler'
require 'nokogiri'

class Tj < Crawler
    attr_reader :song_tjnum, :uri
    # attr_accessor :song_tjnum

## => FLOW ZONE    
    public
        def initialize(song_tjnum)
            @uri                = ""
            @html_doc           = ""
            
            # => set var song's attributes
            @song_tjnum         = song_tjnum
            @song_title         = ""
            @artist_name        = ""
            @writer             = ""
            @composer           = ""
            
            # => set var parsing location
            @info_location      = ""
            @song_title_loc     = ""
            @artist_name_loc    = ""
            @writer_loc         = ""
            @composer_loc       = ""
            
        end
    
    # public   
        def get_uri(target)
            case target
            when "month_new"
                @uri = "https://www.tjmedia.co.kr/tjsong/song_monthNew.asp?YY=#{yyyy}&MM=#{mm}"
            when "song_tjnum"
                @uri = "http://www.tjmedia.co.kr/tjsong/song_search_list.asp?strType=16&strText=#{@song_tjnum}&strCond=0&strSize01=100&strSize02=15&strSize03=15&strSize04=15&strSize05=15"
                @song_title_loc     = "//td.left"
                @artist_name_loc    = "//td:nth-child(3)"
                @writer_loc         = "//td:nth-child(4)"
                @composer_loc       = "//td:nth-child(5)"
            end
        end
        
    # public
        def load_page(uri)
            @html_doc = super
            result = true
            
            if @html_doc == nil || @html_doc.css("table.board_type1").first == nil
                result      = false
                @html_doc   = ""
                return result
            end

            parser = @html_doc.css("table.board_type1").first.css("tbody//tr")
            if parser == nil || parser.length <= 1
                result      = false
                @html_doc   = ""
                return result
            end
        end
        
    # public
        def pick_one
            size = @html_doc.css("div#BoardType1//table.board_type1//tbody//tr").to_a.size
            Console.put("/* pick_one */", "size : #{size}")
            status, @info_location = search_correct(@html_doc, @song_tjnum, size)
            if status == "false"
                return false
            end
            return status, @info_location
        end
        
    private
        ## 많은 검색 결과 중 원하는 노래 한개를 찾는 함수 search_correct
        def search_correct(html_doc, song_tjnum, size) 
            result = ""
            info_location = ""
            size.times do |k|
                info_location = "div#BoardType1//table.board_type1//tbody//tr:nth-child(#{k+1})"
                aa      = html_doc.css(info_location + "//td:nth-child(1)").inner_html.gsub('</span>','').gsub('<span','').gsub('class="txt">','').gsub(' ','')
                Console.put("/* valid */ [exploring]", "current number : #{aa}")
                if aa != song_tjnum.to_i.to_s
                    Console.put("/* valid */ [exploring]", "#{song_tjnum} is NOT FOUND")
                    result = "false"
                else
                    Console.put("/* valid */ [exploring]", "#{song_tjnum} is FOUND !!")
                    result = "true"
                end
                break if result == "true"
            end
            
            return result, info_location
        end
        
    public
        def parsing_info
            # => i have this already ^^
            # @info_location
            # @song_tjnum
            
            # => configuration
            @song_title_loc     = @info_location + @song_title_loc
            @artist_name_loc    = @info_location + @artist_name_loc
            @writer_loc         = @info_location + @writer_loc
            @composer_loc       = @info_location + @composer_loc
            
            # => parser
            @song_title  = @html_doc.css(@song_title_loc).inner_html.to_s
            @artist_name = @html_doc.css(@artist_name_loc).inner_html.to_s
            @writer      = @html_doc.css(@writer_loc).inner_html.to_s
            @composer    = @html_doc.css(@composer_loc).inner_html.to_s
            
            result = {
                song_tjnum:     @song_tjnum,
                title:          @song_title,
                artist_name:    @artist_name,
                writer:         @writer,
                composer:       @composer
            }
            
            return result
        end

## => FEATURES ZONE
    public
        # => 한 곡 크롤링
        def self.crawl(song_tjnum)
            start = Console.now("start at")         # => 시작 시간 명시
            
            tj = Tj.new(song_tjnum)                 # => TJ 객체 생성, 크롤할 곡의 TJ번호를 객체에 저장해줌. 
            tj.get_uri("song_tjnum")                # => 크롤하기 위해 필요한 html페이지 주소와 필요한 정보들의 위치를 tj객체의 attributes에 저장.
            tj.load_page(tj.uri)                    # => get_uri에서 저장된 tj의 uri가 적절한 페이지일 경우 페이지를 연다.
            is_continue = tj.pick_one               # => 열린페이지에서 원하는 곡을 선택.
            
            Console.put("/* CANCELED */", song_tjnum)   if is_continue == false
            return false                                if is_continue == false
            # 여기서부터 pick_one에서 선택한 곡의 정보를 긁어와서 저장함.
            attrs    = tj.parsing_info
            song     = tj.set_song_instance(tj.song_tjnum)
            complete = tj.set_song_attribute(song, attrs)
            tj.save(complete).to_i
            
            stop = Console.now("stop at")
            Console.runtime(start, stop)
        end
        
        # => 여러 곡 크롤링 [ 인자를 각각 기본설정값에 따라 동작하려면 0을 넣는다. ]
        def self.crawl_many(start_tjnum, count, condition)
            # => 변수 상세 설명.
            # start_tjnum:  크롤링을 시작할 tjnum (사용성 고려하여 변수명 변조, 이후 song_tjnum과 동일시.)
            # count:        몇 회 반복시키고 싶은지. -> 몇 회 남았는지.
            # count_origin: 최초 주문한 반복 횟수.
            # i:            몇 곡 저장했는지.
            
            start = Console.now("start at")
            
            # => set default case config
            start_tjnum = 1         if start_tjnum == 0
            count       = 1000      if count == 0
            condition   = 10        if condition == 0
            
            # => rocate
            songs        = []
            song_tjnum   = start_tjnum
            count_origin = count
            i = 0
            loop do
                count -= 1
                Console.put("Now SONG","tjnum : #{song_tjnum}, #{count} LEAVES")
                unless Song.where(song_tjnum: song_tjnum).take.nil?
                    song_tjnum += 1
                    break if count <= 0
                    next
                end
                
                Console.put("AND START","tjnum : #{song_tjnum}, [#{count_origin - count}/#{count_origin}] SOON.")
                song = Tj.crawl(song_tjnum)
                if song != false
                    songs << song.id
                    i += 1
                end
                song_tjnum += 1
                
                break if count <= 0
            end
            
            stop = Console.now("stop at")
            Console.runtime(start, stop)
        end
end