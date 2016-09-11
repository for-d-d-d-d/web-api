class AnalyzerController < ApplicationController
	
	def recom_accuracy # 추천받은 곡 중 몇 %의 노래가 마이리스트에 추가되었는지 계산하는 함수(추천의 정확성)
		data = ForAnalyze.find(1) 	
		result = Mylist_song.where(hometown: "from_recom").count / data.count_recomm * 한번추천에 추천되는 곡수*100  
		return result
	end

	def recom_reliability # 마이리스트에 있는 노래들 중 몇 %의 노래가 추천을 통해 들어왔는지 계산하는 함수(추천의 신뢰성)  
 		result=모든 User의 MyListSongs.where(hometown: "from_recom").count / 모든User의 MylistSongs.count *100
		return result  
	end

end
	