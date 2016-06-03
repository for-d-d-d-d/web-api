class CrawlJob < ActiveJob::Base
  queue_as :default
  class << self; attr_accessor :now end
  class << self; attr_accessor :percent end
  @now = 0
  @percent = 0

  # def self.now
  #     @@now
  # end
  #
  # def self.percent
  #     @@percent
  # end

  def perform(number)
      @now = 0
      #-----------------------------------------------------------------------------------------------------
      # Setting( Focus.한번에 몇개 긁어올지 - 권장 20개, 장기크롤링 - 100개 )
      ## 정탐색 갯수 설정(파생탐색 및 탐색 손실은 측정하지 않음)
      # 갯수 지정 안할 시 기본값 1천개(예상 소요시간: 5분)
      how_many_songs_do_you_want = number
      # 지정된 갯수대로 크롤링(속도: 100여개/30초, 200여개/분, 2천여개/10분)
      # how_many_songs_do_you_want = params[:id].to_i unless params[:id].nil?
      ## 언제부터
      if Song.last == nil
          @start_num = 79999991   # 예제) 82425426 번은 악동뮤지션 200% 곡의 넘버임
      else
          # @start_num = 79999991
          @start_num = Song.last.song_num + 1
      end
      # last_saved_song_count = Song.count
    #   @start_num = params[:start_at].to_i unless params[:start_at].nil?

      #멈춰야하는 SongNumber
      @must_break_id_limit_count = @start_num + how_many_songs_do_you_want
      #-----------------------------------------------------------------------------------------------------

      num = @start_num - 1
      loop do
          @now += 1
          @percent = ((@now.to_f / number.to_f) * 100)
          break if num >= @must_break_id_limit_count
          num += 1
          next if Song.where(song_num: num).take.present?
          next if Song.crawl(num) == false
      end

      # Start debugger
      @message = how_many_songs_do_you_want.to_s + "개 저장완료! 확인하셈!"
      # End debugger
    #   render layout: false
    #   puts "요청하신 크롤링이 종료되었습니다."
  end
end
