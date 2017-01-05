require 'crawler'
require 'nokogiri'

class Tj < Crawler
    attr_reader :year, :month, :day, :year2, :month2, :day2
    attr_accessor :year, :month, :day, :year2, :month2, :day2
    
    attr_reader :song_tjnum, :uri, :info_location
    attr_accessor :song_tjnum
    

## => FLOW ZONE    
    public
        def initialize
            @uri                = ""
            @html_doc           = ""
            
            # => set var song's attributes
            @song_tjnum         = 0
            @song_title         = ""    
            @artist_name        = ""
            @writer             = ""
            @composer           = ""
            
            # => set var parsing location
            @info_location      = ""
            @song_tjnum_loc     = ""
            @song_title_loc     = ""
            @artist_name_loc    = ""
            @writer_loc         = ""
            @composer_loc       = ""
            
            # => set other variable
            @year, @month, @day     = 0, 0, 0
            @year2, @month2, @day2  = 0, 0, 0
        end
    
    # public   
        def get_uri(target)
            case target
            when "month_new"
                @uri = "https://www.tjmedia.co.kr/tjsong/song_monthNew.asp?YY=#{@year}&MM=#{@month}"
            when "search_tjnum"
                @uri = "http://www.tjmedia.co.kr/tjsong/song_search_list.asp?strType=16&strText=#{@song_tjnum}&strCond=0&strSize01=100&strSize02=15&strSize03=15&strSize04=15&strSize05=15"
            when "popular"
                @uri = "http://m.tjmedia.co.kr/tjsong/song_Popular.asp?SYY=#{@year}&SMM=#{@month}&SDD=#{@day}&EYY=#{@year2}&EMM=#{@month2}&EDD=#{@day2}"
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
        
        def get_row_size
            return @html_doc.css("div#BoardType1//table.board_type1//tbody//tr").to_a.size
        end
        
        def set_location(nth_row)
            @info_location = "div#BoardType1//table.board_type1//tbody//tr:nth-child(#{nth_row})"
        end
        
        def set_term(type, date)
            now         = date
            start_date  = now
            end_date    = now
            
            case type
            when "daily"
                start_date  = now - 1.day
                end_date    = now - 1.day
            when "weekly"
                before_year   = now.year
                before_cweek  = now.cweek - 1
                
                if before_cweek.zero?
                    before_year  = now.year - 1
                    before_cweek = 52
                end
                
                start_date  = Date.commercial(before_year, before_cweek, 1)
                end_date    = Date.commercial(before_year, before_cweek, 7)
            when "monthly"
                
                
                start_date  = now - 1.day
                end_date    = now - 1.day
            end
            
            @year,  @month,  @day   = start_date.year, start_date.month, start_date.day
            @year2, @month2, @day2  = end_date.year, end_date.month, end_date.day
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
        def parsing_info(target)
            # => i have this already ^^
            # @info_location
            @song_title_loc     = "//td.left"
            @artist_name_loc    = "//td:nth-child(3)"
            @writer_loc         = "//td:nth-child(4)"
            @composer_loc       = "//td:nth-child(5)"
            
            # => target case for custom
            case target
            when "month_new"
                @song_tjnum_loc = "//td:nth-child(1)"
                @song_tjnum_loc = @info_location + @song_tjnum_loc
                @song_tjnum     = @html_doc.css(@song_tjnum_loc).inner_html.to_s
            when "search_tjnum"
                # edit
            when "popular"
                rank_loc            = "//td:nth-child(1)"
                @song_tjnum_loc     = "//td:nth-child(2)"
                
                rank_loc            = @info_location + rank_loc
                @song_tjnum_loc     = @info_location + @song_tjnum_loc
                
                rank                = @html_doc.css(rank_loc).inner_html.to_s
                @song_tjnum         = @html_doc.css(@song_tjnum_loc).inner_html.to_s
                
                symd                = Date.new(@year, @month, @day).to_s
                eymd                = Date.new(@year2, @month2, @day2).to_s
                @artist_name_loc    = "//td:nth-child(4)"
            end
            
            # => configuration
            @song_title_loc     = @info_location + @song_title_loc
            @artist_name_loc    = @info_location + @artist_name_loc
            @writer_loc         = @info_location + @writer_loc      unless target == "popular"
            @composer_loc       = @info_location + @composer_loc    unless target == "popular"
            
            # => parser
            @song_title  = @html_doc.css(@song_title_loc).inner_html.to_s
            @artist_name = @html_doc.css(@artist_name_loc).inner_html.to_s
            @writer      = @html_doc.css(@writer_loc).inner_html.to_s
            @composer    = @html_doc.css(@composer_loc).inner_html.to_s
            
            # => make return hash
            result = {}
            result[:song_tjnum]     = @song_tjnum
            result[:title]          = @song_title
            result[:artist_name]    = @artist_name
            result[:writer]         = @writer       unless target == "popular"
            result[:composer]       = @composer     unless target == "popular"
            result[:rank]           = rank          if target == "popular"
            result[:symd]           = symd          if target == "popular"
            result[:eymd]           = eymd          if target == "popular"
            
            return result
        end
        

## => FEATURES ZONE
    public
        # => 한 곡 크롤링
        def self.crawl(song_tjnum)
            start = Console.now("start at")         # => 시작 시간 명시
            
            tj = Tj.new                             # => TJ 객체 생성, 크롤할 곡의 TJ번호를 객체에 저장해줌. 
            tj.song_tjnum = song_tjnum
            tj.get_uri("search_tjnum")              # => 크롤하기 위해 필요한 html페이지 주소와 필요한 정보들의 위치를 tj객체의 attributes에 저장.
            tj.load_page(tj.uri)                    # => get_uri에서 저장된 tj의 uri가 적절한 페이지일 경우 페이지를 연다.
            is_continue = tj.pick_one               # => 열린페이지에서 원하는 곡을 선택.
            
            Console.put("/* CANCELED */", song_tjnum)   if is_continue == false
            return false                                if is_continue == false
            
            # => 여기서부터 pick_one에서 선택한 곡의 정보를 긁어와서 저장함.
            attrs    = tj.parsing_info("search_tjnum")
            song     = tj.set_song_instance(tj.song_tjnum)
            complete = tj.set_song_attribute(song, attrs)
            tj.save(complete)
            
            stop = Console.now("stop at")
            Console.runtime(start, stop)
        end
        
        # => 여러 곡 크롤링
        def self.crawl_many(start_tjnum: 0, count: 0, condition: 0)
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
            
            # => flow
            songs        = []
            song_tjnum   = start_tjnum
            count_origin = count
            i = 0
            loop do
                count -= 1
                Console.put("Now SONG","tjnum : #{song_tjnum}, #{count} LEFT")
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
        
        # => 이 달의 신곡 크롤링: 한 달 (기본값: 이번달)
        def self.monthly_crawl(year = 0, month = 0)
            start = Console.now("start at")
            
            # => set-up environment variable
            year    = Time.zone.now.year.to_s    if year == 0
            month   = Time.zone.now.month.to_s   if month == 0
            
            year    = year.to_s
            month   = month.to_s
            month   = "0#{month}" if month.length == 1
            
            # => crawler act
            tj = Tj.new
            tj.year     = year
            tj.month    = month
            tj.get_uri("month_new")
            tj.load_page(tj.uri)
            size = tj.get_row_size
            
            (2..size).to_a.each do |nth_row|
                Console.put("start loop (#{nth_row})", nth_row)
                
                tj.set_location(nth_row)
                attrs    = tj.parsing_info("month_new")
                song     = tj.set_song_instance(tj.song_tjnum)
                complete = tj.set_song_attribute(song, attrs)
                tj.save(complete)
                
                Console.put("end loop (#{nth_row})", complete)
            end
            
            stop = Console.now("stop at")
            Console.runtime(start, stop)
        end
        
        # => 전체 월간 신곡 크롤링
        def self.monthly_crawl_many(start_year, start_month, stop_year = 0, stop_month = 0)
            start = Console.now("start at")
            
            year, month = start_year, start_month
            stop_year, stop_month = Time.zone.now.year, Time.zone.now.month if stop_year == 0 || stop_month == 0
            
            loop do
                if month == 13
                   year += 1; month = 1;
                end
                
                Console.put("monthly_crawl_many.. ..ing. NOW:", "#{year}-#{month}")
                
                Tj.monthly_crawl(year, month)
                break if year == stop_year.to_i && month == stop_month.to_i
                month += 1
            end
            
            stop = Console.now("stop at")
            Console.runtime(start, stop)
        end
        
        # => 단위 인기차트 크롤링: 단위기간 설정 가능 (기본값: 매일, 현재날짜)
        def self.popular(type: "daily", time: Time.current.to_date.to_formatted_s(:number).to_i, count: 1, offset: 0)
                                                # Method Guide
                                                #   =>  [   # 'type' and 'time' are optional arguments
                                                #           Tj.popular # works
                                                #           Tj.popular(type: "weekly", time: 20170105) # works
                                                #           Tj.popular(type: "weekly") # works
                                                #       ]
                                                #   => 'type' can take only three kinds of String. ["daily"/"weekly"/"monthly"]
                                                #       (기본값이 "daily"인 옵션형 argument이나, 값을 명시해 사용할 것을 권장함.)
                                                #   => 'time' can take any 'yyyymmdd' formatted Integer such as 20170105. 
                                                #       (날짜와 그 형식이 올바르다면, 어느 날짜를 집어넣든지 올바른 연산을 처리함.)
            start = Console.now("start at")
            
            tj = Tj.new
            time = Mytime.yyyymmdd_to_date(time)
            count.times do |i|
                i += offset
                date = time - i.day    if type == "daily"
                date = time - i.week   if type == "weekly"
                date = time - i.month  if type == "monthly"
                
                tj.set_term(type, date)
                tj.get_uri("popular")
                tj.load_page(tj.uri)
                size = tj.get_row_size
                
                (2..size).to_a.each do |nth_row|
                    Console.put("start loop (#{nth_row})", nth_row)
                    
                    tj.set_location(nth_row)
                    attrs    = tj.parsing_info("popular")
                    song     = tj.set_song_instance(tj.song_tjnum, table: "DailyTjPopularRank", symd: attrs[:symd], eymd: attrs[:eymd])
                    complete = tj.set_song_attribute(song, attrs)
                    result   = tj.save(complete)
                    
                    Console.put("end loop (#{nth_row})", result)
                end
            end
            
            stop = Console.now("stop at")
            Console.runtime(start, stop)
            return {repeat: count, time: time}
        end
        
        # => 전체 인기차트 크롤링
        def popular_all(type: "daily")
            start = Console.now("start at")
            
            # Tj.popular(type: type, count: count)
            
            stop = Console.now("stop at")
            Console.runtime(start, stop)    
        end
        
        
        # => you can custom this feature method format by copy & paste
        # def self.method_names(some_parameters)
        #     start = Console.now("start at")
            
        #     # some codes
            
        #     stop = Console.now("stop at")
        #     Console.runtime(start, stop)
        # end
end