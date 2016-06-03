class Mylist < ActiveRecord::Base
  belongs_to :user
  has_many :mylist_songs

  def songs
      return self.mylist_songs
  end
end
