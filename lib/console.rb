class Console
    def self.put(label, arg)
        puts "\n\t#{label} ~> \t#{arg}\n"
    end
    
    def self.now(comment)
        time = Time.zone.now
        puts "\n\n#{comment} >>>>>>>>>>>>>\t#{time}\n\n\n"
        return time
    end
    
    def self.runtime(start, stop)
        seconds = stop - start
        time = Time.at(seconds).utc.strftime("%I:%M%p")
        puts "\n\nruntime *************\t #{time} \t*************\n\n\n"
    end
end