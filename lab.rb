# arr = []
t = gets.chomp
t = t.to_i
(1..t).to_a.map{|i| "t#{i} = gets.chomp"}.each do |st| 
    # eval(st)
    puts st
    # real = nil
    # x1 = eval("t" + ti.to_s).split(' ').first(1).last.to_i
    # y1 = eval("t" + ti.to_s).split(' ').first(2).last.to_i
    # r1 = eval("t" + ti.to_s).split(' ').first(3).last.to_i
    # x2 = eval("t" + ti.to_s).split(' ').first(4).last.to_i
    # y2 = eval("t" + ti.to_s).split(' ').first(5).last.to_i
    # r2 = eval("t" + ti.to_s).split(' ').first(6).last.to_i
    
    # d1 = Math.sqrt((x2 - x1)**2 + (y2 - y1)**2) # 두 중점간 거리
    # d2 = r1 + r2    # 두 반지름의 합
    # if ((x2 - x1)**2 + (y2 - y1)**2) == 0   # 일치
    #     real = -1
    # elsif d1 == (r2 - r1).abs   # 내접
    #     real = 1
    # elsif d1 < d2
    #     real = 2
    # elsif d1 == d2  # 외접
    #     real = 1
    # elsif d1 > d2 
    #     real = 0
    # end
    # puts real
end

# (1..t).to_a.each do |ti|
#     real = nil
#     x1 = eval("t" + ti.to_s).split(' ').first(1).last.to_i
#     y1 = eval("t" + ti.to_s).split(' ').first(2).last.to_i
#     r1 = eval("t" + ti.to_s).split(' ').first(3).last.to_i
#     x2 = eval("t" + ti.to_s).split(' ').first(4).last.to_i
#     y2 = eval("t" + ti.to_s).split(' ').first(5).last.to_i
#     r2 = eval("t" + ti.to_s).split(' ').first(6).last.to_i
    
#     d1 = Math.sqrt((x2 - x1)**2 + (y2 - y1)**2) # 두 중점간 거리
#     d2 = r1 + r2    # 두 반지름의 합
#     if ((x2 - x1)**2 + (y2 - y1)**2) == 0   # 일치
#         real = -1
#     elsif d1 == (r2 - r1).abs   # 내접
#         real = 1
#     elsif d1 < d2
#         real = 2
#     elsif d1 == d2  # 외접
#         real = 1
#     elsif d1 > d2 
#         real = 0
#     end
#     puts real
# end
