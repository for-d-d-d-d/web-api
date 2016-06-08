class CreateSongs < ActiveRecord::Migration
  def change
    create_table :songs do |t|

      # Relation
      t.integer :album_id       # =>앨범아이디(1:N 릴레이션)
      t.integer :singer_id      # =>가수아이디(1:N 릴레이션)
      t.integer :team_id        # =>팀아이디(1:M 릴레이션)

      # 음원 정보(보통)
      t.string  :title          # =>제목
      t.string  :ganre1         # =>장르1
      t.string  :ganre2         # =>장르2
      t.string  :runtime        # =>재생시간
      t.text    :lyrics         # =>가사
      t.string  :writer         # =>작사
      t.string  :composer       # =>작곡
      t.string  :youtube        # =>뮤비주소 아이디값

      # 음원 정보(참조)
      # t.integer :artist_num     # =>아티스트 번호(Default : 팀 단위)
      # t.integer :album_num      # =>앨범 번호번호번호번호번호

      # 음원 정보(참조추출)
      # t.text    :artist_photo   # =>아티스트 사진(아티스트테이블로부터 불러와 저장)
      t.text    :jacket         # =>자켓사진(앨범테이블로부터 불러와 저장)

      # 음원 정보(고유값)
      t.integer :song_tjnum     # =>TJ미디어 기준, 노래방번호
      t.integer :song_num       # =>음원의 지니뮤직 고유번호

      # 음원 정보(음역)
      t.string  :lowkey         # =>음원의 가장 낮은 키
      t.string  :highkey        # =>음원의 가장 높은 키

      t.timestamps null: false
    end
  end
end
