# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/home/ec2-user/web-api/log/cron_log.log"
# set :output, "/path/to/my/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever

# set :environment, "development"

#every 1.day do
#  # exec
#  runner "CrawlController.run(500000, nil)"#, :environment => "development"
#  
#  # dump ready
#  command "mkdir /home/ec2-user/web-api/public/seeds/#{Time.new.to_s.gsub('-','').gsub(' ','_').gsub(':','').gsub('+','')}"
#  command "touch /home/ec2-user/web-api/public/seeds/#{Time.new.to_s.gsub('-','').gsub(' ','_').gsub(':','').gsub('+','')}/seed.rb"
#  command "cp /home/ec2-user/web-api/db/seeds.rb /home/ec2-user/web-api/public/seeds/#{Time.new.to_s.gsub('-','').gsub(' ','_').gsub(':','').gsub('+','')}/seed.rb"
#  
#  # dump
#  rake "db:seed:dump RAILS_ENV=production"
#end






# 1.minute 1.day 1.week 1.month 1.year is also supported
# every 3.hours do 
#   runner "MyModel.some_process"
#   rake "my:rake:task"
#   command "/usr/bin/my_great_command"
# end

# every 1.day, :at => '4:30 am' do
#   runner "MyModel.task_to_run_at_four_thirty_in_the_morning"
# end


# Many shortcuts available: :hour, :day, :month, :year, :reboot
# every :hour do 
#   runner "SomeModel.ladeeda"
# end


# Use any day of the week or :weekend, :weekday
# every :sunday, :at => '12pm' do 
#   runner "Task.do_something_great"
# end

# every '0 0 27-31 * *' do
#   command "echo 'you can use raw cron syntax too'"
# end

# # run this task only on servers with the :app role in Capistrano
# # see Capistrano roles section below
# every :day, :at => '12:20am', :roles => [:app] do
#   rake "app_server:task"
# end


# job_type :command, ":task :output"
# job_type :rake,    "cd :path && :environment_variable=:environment bundle exec rake :task --silent :output"
# job_type :runner,  "cd :path && bin/rails runner -e :environment ':task' :output"
# job_type :script,  "cd :path && :environment_variable=:environment bundle exec script/:task :output"
