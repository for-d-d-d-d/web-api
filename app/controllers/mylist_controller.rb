class MylistController < ApplicationController

    def add
        id = params[:id]

        s = Song.where(id: id).first
        if s.nil?
            flash[:error] = "존재하지 않은 곡입니다."
            redirect_to :back
            return false
        end

        m = Mylist.new
        m.song_id = s.id
        m.user_id = current_user.id
        m.save
    end

    def delete
        Mylist.find(params[:id]).destroy
        redirect_to :back
    end

    
end
