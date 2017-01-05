class Mytime < Util
    def self.yyyymmdd_to_date(int)
        str     = int.to_s
        year    = str.first(4).to_i
        month   = str.first(6).last(2).to_i
        day     = str.last(2).to_i
        return Date.new(year, month, day)
    end
end