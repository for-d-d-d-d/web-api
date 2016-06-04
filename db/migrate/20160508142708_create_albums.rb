class CreateAlbums < ActiveRecord::Migration
  def change
    create_table :albums do |t|
      # 앨범 정보(보통)
      t.string  :title            # =>제목
      t.string  :ganre1           # =>장르1
      t.string  :ganre2           # =>장르2
      t.string  :publisher        # =>발매사
      t.string  :agency           # =>기획사
      t.string  :released_date    # =>발매일
      t.text    :jacket           # =>자켓사진(이미지)

      # 앨범 정보(참조)
      # t.integer :artist_num       # =>아티스트 번호(Default : 팀 단위)

      # 앨범 정보(참조추출)
    #   t.integer :team_id
    #   t.integer :singer_id
      # t.text    :artist_photo     # =>아티스트 사진(아티스트테이블로부터 불러와 저장)
      # t.string  :artist_name      # =>아티스트 이름(아티스트테이블 만들기전까진 임의로 박아둔다)

      # 앨범 정보(고유값)
      t.integer :album_num        # =>앨범 번호

      t.timestamps null: false
    end
  end
end
