class MylistController < ApplicationController

    def add_list
        m = Mylist.new
        m.title = params[:title]
        m.user_id = current_user.id
        m.save
        redirect_to :back
    end

    def add
        id = params[:id]

        s = Song.where(id: id).first
        if s.nil?
            flash[:error] = "존재하지 않은 곡입니다."
            redirect_to :back
            return false
        end

        if current_user.mylists.where(title: "Default").first.nil?
            a = Mylist.new
            a.user_id = current_user.id
            a.title = "Default"
            a.save
        end

        if current_user.mylists.where(title: "Default").first.mylist_songs.where(id: s.id).exists?
            flash[:error] ="이미 추가된 곡입니다"
            redirect_to :back
            return
        end

        m = MylistSong.new
        m.song_id = s.id

        m.mylist_id = Mylist.where(title: "Default").first.id
        m.save

        flash[:error] = "추가 완료 추가된 곡 :" + m.song.title
        redirect_to :back
    end

    def delete
        MylistSong.find(params[:id]).destroy
        redirect_to :back
    end

    def list
        t = params[:title]

    end

end
