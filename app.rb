require 'sinatra/base'
require_relative 'student-orm-new/lib/models/student'
require 'sqlite3'

# Why is it a good idea to wrap our App class in a module?
module StudentSite
  class App < Sinatra::Base

    get '/' do
      "hello world!"
    end

    get '/hello-world' do
      @random_numbers = (1..20).to_a
      erb :hello
    end

    get '/artists' do
      @artists = ["James Taylor", "Frank Sinatra", "Louis Armstrong"]
      erb :artists
    end

    get '/students' do
      @students = Student.all
      erb :students
    end

    get '/:name' do
      @students = Student.all.find(params[:name])
      erb :student_pro
    end

  end
end