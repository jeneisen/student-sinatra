require 'nokogiri'
require 'open-uri'
require 'sqlite3'

class Student
  attr_reader :student_page, :url, :student_hash
  attr_accessor :name, :twitter, :linkedin, :quote, :last_name
  @@all = []
  @@database = nil
  def self.all 
    @@all
  end
  
  def self.find_by_last_name(lastname)
    self.all.select{|student| student[:last_name] == lastname}
  end


  def database
    if @@database 
      @@database.save(self.student_hash)
    else
      @@database = Database.new('students_database.db')
    end
  end

  def initialize(url)
    @url = url 
    @student_page = Nokogiri::HTML(open(url))
    define_attributes_of_student
    student_attributes
    database
  end

  def define_attributes_of_student
    @student_data = StudentScraper.new(self.student_page)
    self.name = @student_data.name
    self.twitter = @student_data.twitter
    self.linkedin = @student_data.linkedin
    self.quote = @student_data.quote
  end

  def student_attributes
    @student_hash = {}
    student_hash[:url] = self.url
    student_hash[:name] = self.name
    student_hash[:twitter] = self.twitter
    student_hash[:linkedin] = self.linkedin
    student_hash[:quote] = self.quote
    student_hash[:last_name] = self.name.split.last.downcase.strip
     @@all << student_hash
    @student_hash
  end

end

class StudentScraper

  attr_reader :profile_page

  def initialize(student_page)
    @profile_page = student_page
  end

  def name
    self.profile_page.search('div.page-title h4.ib_main_header').text.strip
  end

  def twitter
    self.profile_page.search('div.social-icons a').first.attr('href').strip
  end

  def linkedin
    self.profile_page.search('div.social-icons a')[1].attr('href').strip
  end

  def github
    self.profile_page.search('div.social-icons a')[2].attr('href').strip  
  end 

  def quote
    self.profile_page.search('li#text-7 div.textwidget h3').text.strip
  end

end

class Database  #Not too sure about this one
    #Wrap in the initialize method definition?
  def initialize(database_name)  
    @db = SQLite3::Database.new database_name #<=#CHANGE
    rows = @db.execute <<-SQL
      create table if not exists students (
      id INTEGER PRIMARY KEY,
      url varchar(255),
      name varchar(255),
      twitter varchar(255),
      linkedin text,
      quote text       
      );
    SQL
  end

  def save(student_hash)
      @db.execute("INSERT INTO students (url, name, twitter, linkedin, quote)
                  VALUES (?, ?, ?, ?, ?)", [student_hash[:url], student_hash[:name],
                student_hash[:twitter], student_hash[:linkedin], student_hash[:quote]])
   end     
end

#Write a loop that will extract every student profile link from
# the students.flatironschool.com/index page and then 
# instantiate an instance of the Student class, which will 
# automatically add that instance to the database


def urls
  doc = Nokogiri::HTML(open('http://students.flatironschool.com'))
  url_search = doc.search('.blog-title .big-comment h3')
  url_collector(url_search)
end

def url_collector(url_search)
  url_search.collect do |i|
    if i.children.attr("href")
      "http://students.flatironschool.com/" + i.children.attr("href").value.downcase
    else
       '#'
    end
  end
end


def collect_student_data(student_urls)
  student_urls.each do |url|
    begin
      student_index = student_urls.index(url)
      profile_page = Nokogiri::HTML(open(url))
      if url != 'http://students.flatironschool.com/#' && url != '#'
        # puts url
        Student.new(url)
      end
    rescue => e
      puts "Error: #{e}"
      next 
    end  
  end
end

collect_student_data(urls)









