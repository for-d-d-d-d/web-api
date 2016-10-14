class SongController < ApplicationController
  def song_save
    a = Song.new
    a.title   = params[:title]
    a.artist  = params[:artist]
    a.lowkey  = params[:lowkey]
    a.highkey = params[:highkey]
    
      ##### TJ 노래방 번호 자동 크롤링
      song_title  = params[:title].to_s.gsub(" ","%20")
      
      tj_uri        = "http://www.tjmedia.co.kr/tjsong/song_search_list.asp?strType=0&strText=#{song_title}&strCond=0&strSize01=100&strSize02=15&strSize03=15&strSize04=15&strSize05=15"
      # html_doc    = Nokogiri::HTML(Net::HTTP.get(tj_uri))
      
      # select_1 = html_doc.css("table.board_type1//tr:nth-child()")
      # select_2 = html_doc.css("")
      # select_3 = html_doc.css("")
      
      a.tjnum   = tj_uri
      
      
      ##### 지니음원 id 자동 크롤링
      # song_title  = params[:title].to_s.gsub(" ","%20")
      
      gini_uri      = "http://www.genie.co.kr/search/searchMain?query=#{song_title}&x=0&y=0"
      
      a.gininum = gini_uri
    
    a.save
    redirect_to :back
  end
  
  def song_num_save
    a = Song.find(params[:id])
    unless params[:tjNum].nil?
        a.tjnum = params[:tjNum]
    end
    unless params[:giniNum].nil? || params[:giniNum].length < 1
        if Song.where(song_num: params[:giniNum]).take == nil
            if user_signed_in?
                if User.find(current_user.id).email.split('@').last.split('.').first == "4d"
                    user = User.find(current_user.id)
                    user.uid = user.uid.gsub('[','').gsub(']','').split(', ').map{|a| a.to_i}.push(params[:id].to_i).to_s if user.uid != nil
                    user.uid = "[#{params[:id]}]" if user.uid == nil
                end
            end
            a.song_num = params[:giniNum]
            a.crawl_song
            if Song.where(song_num: params[:giniNum]).take != nil
                user.save
            end
        end
    end
    if params[:ajax_search].nil?
        # redirect_to :back
    else
        render json: {  Message: "'#{a.title} - #{a.artist_name}'이 성공적으로 저장되었습니다." }
    end
  end

  def song_delete
    if params[:confirm] == "true"
      unless Administer.where(username: "#{params[:username]}", password: "#{params[:password]}").take.nil?
        a = Song.find(params[:id])
        a.delete
        redirect_to '/admin/songs_info'
      else
        @song = Song.find(params[:id])
        render layout: false
      end
    else
      @song = Song.find(params[:id])
      render layout: false
    end
  end
  
  def song_download
    render layout: false
  end
end
