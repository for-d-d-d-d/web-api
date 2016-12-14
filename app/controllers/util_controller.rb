class UtilController < ApplicationController
    
    
    def self.pager(page, arr)
        limit   = 30
        if page == "-1"|| page == nil
            page = 0
        else
            page    = page.to_i
            page    = page unless page.nil?
            page    = 1 if page == 0
        end
    
        if page == 0
            arr = arr
        else
            arr = arr[(limit * (page - 1))..((limit * page)-1)]
        end
        return arr
    end
    
    # fn() INFO ( restAPI server(0) )
    # description : 노래 레코드에 대한 상세정보를 선택적으로 반환하는 함수. 
    # why         : 매번 레코드 정보를 전부 리턴하는 낭비를 방지
    # INPUT       : ids : SongTable의 주key인 id값들을 요소로하는 배열을 문자열 형태로 입력. 
    #               exclude : 레코드 속성중에 제거하고자 하는 불필요한 속성들. Array형태로 입력. 
    #               mytoken : 사용자 토큰(str)
    #               mylist_count : true or false
    # - case      : ids : "[1,2,3]" / "1,2,3" / "[1, 2, 3]" 세가지 형태가 가능하며, 첫 번째 형태를 권장.
    #               exclude : {
    #                     "없을때" : (arrayType) [],
    #                     "1개 이상 존재" : (arrayType) ["", "", ... , ""]
    #                     }
    # OUTPUT      : fn() returns records with hashType for the SongTable.
    def self.detail_songs(ids, exclude, mytoken, mylist_count)
        ids         = ids.to_s if ids.class != String
        song_ids    = UtilController.mapped_string_translater_to_array(ids)
        songs       = song_ids.map{|song_id| Song.find(song_id)}
        
        default = [
            "created_at","updated_at",
            "youtube",
            "lowkey","highkey",
            "jacket","jacket_middle","jacket_small",
            "song_num"
        ]
        
        will_exclude = default + exclude unless exclude == "nil" || exclude == nil || exclude.class != Array
        will_exclude = will_exclude.uniq
        
        attributes = []
        Song.attribute_names.each do |an|
            attributes << an unless will_exclude.include?(an)
        end

        result = []
        songs.each do |song|
            arr = []
            attributes.each do |att|
                eval("arr << [att, song.#{att}]")
                if att == "jacket"
                    if song.jacket.nil?
                        
                    elsif song.jacket == "Error::ThisMusickCanNotFind"
                    end
                end
            end

            if song.song_num.nil?
                arr << ["song_num", 0]
            else
                arr << ["song_num", song.song_num]
            end
            if song.jacket.nil?
                arr << ["jacket", $noReadyJacket_600]
                arr << ["jacket_middle", $noReadyJacket_200]
                arr << ["jacket_small", $noReadyJacket_100]
            elsif song.jacket == "Error::ThisMusickCanNotFind"
                arr << ["jacket", $noReadyJacket_600]
                arr << ["jacket_middle", $noReadyJacket_200]
                arr << ["jacket_small", $noReadyJacket_100]
            else
                arr << ["jacket", song.jacket]
                arr << ["jacket_middle", song.jacket_middle]
                arr << ["jacket_small", song.jacket_small]
            end
            
            if song.album.nil?
                arr << ["release", "세팅 대기중인 곡입니다"]
            else
                release = song.album.released_date.split('')
                release.pop
                release = release.join
                arr << ["release", release]
            end

            is_my_favorite = false
            unless mytoken.nil?
                me = User.where(mytoken: mytoken).take
                mySongs = me.my_songs.map{|ms| ms.id}
                is_my_favorite = true if mySongs.include?(song.id)
                # maybe_mysong = me.mylists.first.mylist_songs.where(song_id: song.id).take
            end
            arr << ["is_my_favorite", is_my_favorite]
            
            if mylist_count == true
                ml_count = MylistSong.where(song_id: song.id).map{|ms| ms.mylist.user}.uniq.count
                arr << ["mylist_count", ml_count]
            end
            result << [song.id, arr.to_h]
        end
        result = result.to_h.to_a.each{|s| s.shift}.flatten

        return result
    end
    
    # fn() INFO
    # description : 문자열 형태로 전달되는 각종 ID값들의 배열을 배열로 변환하는 함수.
    # 1. id값으로 매핑된 문자열만 입력값으로 허용.
    # 2. 매핑된 문자열을 배열 형태로 변환.
    # 3. id값은 반드시 임의의 숫자형태일 것.
    # 4. ex) 가능한 입력형식
    #             "[1,2,3]" / "1,2,3" / "[1, 2, 3]"
    #        불가능한 입력형식
    #             "['1','2','3']" / '["1","2","3"]' / "[\"1\",\"2\",\"3\"]"
    # 5. 권장사항
    #     - int형 element들을 담은 배열을 그대로 문자열로 변환한 형태가 최적의 입력형태.
    def self.mapped_string_translater_to_array(string)
        str0 = string.delete(' ')
        arr0 = str0.split('')
        arr0.shift      if arr0.first == '['
        arr0.pop        if arr0.last  == ']'
        str1 = arr0.join
        arr1 = str1.split(',')
        arr2 = arr1.map{|el| el.to_i}   # 임시 제외 => .map{|el| nil if el == 0}.compact
        result = arr2
        
        return result
    end
    
    def self.filtering_blacklistSongs_from_list(ids, myid)
        me = User.find(myid)
        bl_ids = me.blacklist_songs.map{|s| s.song_id}
        ids = ids - bl_ids
        return ids
    end
      
    #블랙리스트와 마이리스트에 같은노래가 있는오류 수정 기능 함수
    def self.mySong_vs_blacklistSong(me_id)
        me = User.find(me_id)
        mySongs = me.mylists.first.mylist_songs
        blSongs = me.blacklist_songs
        blSongs.each do |bl|
            same_mySong = mySongs.where(song_id: bl.song_id).take
            if same_mySong.nil?
                next
            else
                if same_mySong.created_at.to_s < bl.created_at.to_s
                    same_mySong.delete
                else
                    bl.delete
                end
            end
        end
        return true
    end
    
    # 크롤러 돌리는 서버에서 데이터 백업해서 이 서버에 데이터 저장하는 코드 
    def db_call
        url     = 'http://52.78.146.161/seeds/seeds.rb'
        data    = open(url).read
        send_data data, :disposition => 'attachment', :filename => 'seeds.rb'
        
        @file   = 'true'
        render json: @file 
    end
end
