
original_count = Song.tj_ok.count

check_sharp = []
check_include = []
check_unsharp = []
check_exclude = []

Song.tj_ok.each do |song|
        if song.lyrics.split(//)[0] == '#'
                check_sharp << song

                tjsong = song
                br_split = tjsong.lyrics.split("<br>")
                (0..5).each do |i|
                        if i >= 4
                                if br_split[0].include? "노래"
                                        check_include << song
                                        br_split.delete_at(0)
                                        break
                                end
                         end
                         br_split.delete_at(0)
                 end

                 br_split.count.times do |k|
                        unless br_split[k].nil? || br_split[k].length < 1
                                br_split[k] = br_split[k] + "<br>"
                        end
                 end

                 result = br_split.join
                 puts "#{result}"

                 tjsong.lyrics = result
                 tjsong.save
                 puts "완료"
         else
                check_unsharp << song
         end
end
