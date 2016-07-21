class JsonController < ApplicationController
  def song
    @song = Song.ok.all
    
    render :json => @song
  end
end
