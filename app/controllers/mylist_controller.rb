class MylistController < ApplicationController

    def add_list
        m = Mylist.new
        m.title = params[:title]
        m.user_id = current_user.id
        m.save
        redirect_to :back
    end

    def delete_list
        id = params[:id]
        Mylist.find(id).destroy
        redirect_to :back
    end

    def add
        id = params[:song_id]
        list_id = params[:list_id]

        s = Song.where(id: id).first
        if s.nil?
            flash[:error] = "존재하지 않은 곡입니다."
            redirect_to :back
            return false
        end

        a = current_user.mylists.where(id: list_id).first
        if a.nil?
            a = Mylist.new
            a.user_id = current_user.id
            a.title = "Default"
            a.save
        end

        unless MylistSong.where(mylist_id: a.id, song_id: s.id).empty?
            flash[:error] = "이미 추가된 곡입니다"
            redirect_to :back
            return false
        else
            m = MylistSong.new
            m.song_id = s.id

            m.mylist_id = Mylist.where(id: list_id).first.id
            m.save

            flash[:error] = "추가 완료 :" + m.song.title
            redirect_to :back
        end
    end

    def delete
        id = params[:id]
        MylistSong.find(id).destroy
        redirect_to :back
    end

    def list
        t = params[:title]
    end

end
