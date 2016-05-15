class HomeController < ApplicationController
  def entering
    @bg_img = [
      "http://www.todayjournal.co.kr/news/photo/201509/2786_6024_2539.JPG",
      "http://www.agendalugano.ch/system/images/files/000/008/293/original/fondo_inicio.jpg?1405683396",
      "http://debrown.com.ar/wp-content/uploads/2014/09/certamen.jpg",
      "http://i00.i.aliimg.com/wsphoto/v1/2018739680_3/Tapete-free-Shipping-Fashionable-Flashing-Lights-Karaoke-Bar-Ktv-Entertainment-Clubs-Stage-Backdrop-Mural-Living-Room.jpg",
      "http://melissadreamsofsushi.com/wp-content/uploads/2013/12/DSC003311.jpg",
      "http://www.panicmanual.com/wp-content/uploads/2013/11/karaoke.jpg",
      "http://groupon.co.id/images/picpromobig/5f0f5e5f33945135b874349cfbed4fb976429.jpg"
    ].sample
    #@bg_img = "http://i.blogs.es/70ab15/karaoke-apps-i1/650_1200.jpg"

    # 로그인 되있으면 main2로 가고 로그인 안되있으면 sign_in으로

    # test 용 entering page 보기
    # view/devise/sessions/new.html.erb 에다가 entering 패이지를 옴기새요

    if user_signed_in?
      redirect_to '/home/main'
    else
      redirect_to '/users/sign_in'
    end
  end

  def main
      @song = Song.where.not(lowkey: nil).all
      @carousel = @song.first(1)

      @rankers = DailyTjPopularRank.all

      @ranker = Array.new
      @rankers.each do |r|
          aa = Song.where(song_tjnum: r.song_num).take
          if aa != nil
              @ranker << aa
          end
      end

    #render :layout => false
  end

  def login
    # 비밀번호 일치하면 main2로
    redirect_to '/gorae/main2'

    # 비밀번호 안맞으면
    # 다시 entering으로
  end

  def main2

    render layout: "../gorae_layouts/application.html.erb"
  end

  def search
    if params[:query].nil?
      @query = "검색어를 찾을 수 없습니다."
    else
      @query = "검색어를 찾을 수 없습니다." if params[:query].length == 0
      @query = params[:query] if params[:query].length != 0
    end

    render layout: "../gorae_layouts/application.html.erb"
  end

  def rank

    render layout: "../gorae_layouts/application.html.erb"
  end

  def recommendation
    @action = params[:action]
    render layout: "../gorae_layouts/application.html.erb"
  end

  def mylist

    render layout: "../gorae_layouts/application.html.erb"
  end

  def EvalKey
      
  end
end
