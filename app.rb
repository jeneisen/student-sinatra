require 'sinatra/base'
require_relative 'scraper'
require 'sqlite3'

# Why is it a good idea to wrap our App class in a module?
module StudentSite
  class App < Sinatra::Base
    get '/students' do
      @students = Student.all
      erb :students 
    end

    get '/students/:last_name' do
      @student = Student.find_by_last_name(params[:last_name])
      erb :student_pro
    end
  end
end

#     get '/students' do
#       @students = Student.all
#       erb :students
#     end

#     get '/:name' do
#       @students = Student.all.find(params[:name])
#       erb :student_pro
#     end

#   end
# end