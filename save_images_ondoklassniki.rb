#encoding: UTF-8
require "watir-webdriver"
require "open-uri"
require "watir-webdriver/wait"

def login
  @b = Watir::Browser.new :firefox
  @b.goto "odnoklassniki.ru"
## chose your destiny and comment the not needed ones:) 
  puts "Enter user:"
  usr = gets.chomp
  puts "Enter password:"
  pswd = gets.chomp
## or
# usr = "user@blabla.domain"
# pswd = "your_password_goes_here"
  @b.text_field(:id, "field_email").set(usr)
  @b.text_field(:id, "field_password").set(pswd)
  @b.input(:id, "hook_FormButton_button_go").click
  sleep 1
end

def get_photos
  @b.span(:class => "navMenuCount", :index => 1).click
  @b.span(:class => "tab-nav_i_txt", :index => 1).wait_until_present
  @b.span(:class => "tab-nav_i_txt", :index => 1).click
  @mains = [@b.url]
  @b.span(:class => "tab-nav_i_txt", :index=> 1).text.to_i
  sleep 1
end

def count_photos
  @personal_photos = @b.span(:class => "hcount", :index => 1).text
  puts "Number of personal photos is " + @personal_photos.to_s
  @albums_count = @b.span(:class => "hcount", :index => 2).text
  puts "Number of albums is " + @albums_count.to_s
  @tagged_in = @b.span(:class => "hcount", :index => 3).text
  puts "Number of photos you are tagged in is " + @tagged_in.to_s
  @b.span(:class => "tab-nav_i_txt", :index => 2).click
  @b.div(:class, "photo-sc_grid_i_alb-corner").wait_until_present
  @in_albums = []
    for x in @b.divs(:class, "photo-sc_grid_i_alb-corner").each do
      @in_albums.push(x.text)
    end
#	@in_albums_total = eval @in_albums.join '+'
    for j in 0..@in_albums.count-1 do
      puts "Album " + j.to_s + " has photos count " + @in_albums[j.to_i]
    end
    puts "Total number of photos in all albums besides personal and tagged is " + @in_albums.map(&:to_i).reduce(:+).to_s
    @b.span(:class => "tab-nav_i_txt", :index => 1).click
    sleep 1
end


def get_albums
  @b.span(:class => "tab-nav_i_txt", :index => 2).click
  sleep 1 until @b.a(:class, "o").exists?
  @albums = []
  @b.as(:class, "o").each do |y|
    if y.href == "" or y.href == " " or y.href.empty? or y.href == "/" or y.href == "/\/" then
      next
    end
    @albums.push(y.href)
    sleep 1
end

def get_tagged
  @b.span(:class => "navMenuCount", :index => 1).click
  @b.span(:class => "tab-nav_i_txt", :index => 3).wait_until_present
  @b.span(:class => "tab-nav_i_txt", :index => 3).click
  @b.img(:class => "photo-sc_grid_img").wait_until_present
  @tagged = [@b.url]
  sleep 1 
end

#.gsub('\W',' ').gsub('\n','').text.gsub('?',' ').gsub(' ','_').gsub(':','').gsub('/','').gsub('\/',' ').gsub('"','')

def save_images(img_arrayclass, photocl, photocl_index, album_title, classs)
  for i in 0..img_arrayclass.count-1
    @b.goto img_arrayclass[i]
    imgcount = @b.span(:class => photocl, :index => photocl_index).text.to_i
    puts "Pictures in an gallery: "+ imgcount.to_s
    @ablum_title = @b.span(:class, album_title).text.gsub("\d","").gsub("\/"," ").gsub("?"," ").gsub(" ","_").gsub('"','').to_s[0..230]
    # @download_directory = "#{Dir.pwd}/"+@ablum_title.gsub(" ","_") #create download dirrectory TBU
    @b.img(:class, "photo-sc_grid_img").click
      for j in 0..imgcount-1 do
        #sleep 1 until @b.img(:class, "plp_photo").exists?
        @b.img(:class, "plp_photo").wait_until_present
        image_url = @b.img(:class, "plp_photo").src
          if @b.div(:id, 'plp_slide_r').exists? == false then
#          File.open(@ablum_title.to_s[0..19] + " " + classs + " " + j.to_s + ".jpg", 'wb') do |f| #limits title to 20 keys
           File.open(@ablum_title.to_s + " " + classs + " " + j.to_s + ".jpg", 'wb') do |f| #limits title to 20 keys
              f.write open(image_url).read
            end
            puts "Breaking if there's no next button, i.e. one image in an album and album title: " + @ablum_title.to_s
            break  
          elsif @b.span(:xpath, "//*[@id='plp_descrCntText']").text.to_s == ""
            #%x(mkdir "@ablum_title") #create dirrectory TBU
            File.open(@ablum_title.to_s + " " + classs + " " + j.to_s + ".jpg", 'wb') do |f|
              f.write open(image_url).read
              puts "Saving img with no title and album name: " + @ablum_title.to_s
            end
          else
            @img_title = @b.span(:xpath, "//*[@id='plp_descrCntText']").text.gsub('\n','').gsub('\W',' ').gsub(':','').gsub('/','').gsub('\/',' ').gsub('?',' ').gsub('"','').gsub("?"," ").gsub(" ","_").to_s[0..210]
            #%x(mkdir "@ablum_title") #create dirrectory TBU
#           File.open(@ablum_title.to_s[0..4] + " " + classs + " " + @img_title.to_s + " " + j.to_s + ".jpg", 'wb') do |f| #limits album title to 5 keys if img has description
            File.open(@ablum_title.to_s + " " + classs + " " + @img_title.to_s + " " + j.to_s + ".jpg", 'wb') do |f|
              f.write open(image_url).read
              puts "Saving img with a title: " + @img_title.to_s
            end
          end
          if @b.i(:class, "tico_img ic ic_i_reload").exists? then
            puts "Breaking if the album reached it's end"
            break
          else
            puts 'Next..' + j.to_s
            @b.div(:id, 'plp_slide_r').click
            sleep 1
        end
      end
      # Magic, do not touch !
    end
  end
end

login
get_photos
puts "Generating an array of main images " + @mains.to_s
count_photos
sleep 1
get_albums
puts "Generating an array of albums " + @albums.to_s
get_tagged
puts "Generating an array of tagged images " + @tagged.to_s
sleep 1

save_images(@mains, "hcount", 1, "tab-nav_i_txt", "mains") # Saves main imgs with title = Личное Фото
sleep 1

#Manual photo savings
#@mains = ['http://www.odnoklassniki.ru/profile/123456789123/pphotos',
#'http://www.odnoklassniki.ru/profile/123456789123/pphotos',
#   ...     'n']

save_images(@albums, "photo-sc_h2_alb-count", 0, "photo-sc_h2_alb-title", "albums") #Saves images from all of your albums = Фотоальбомы 
sleep 1

#Manual album savings
#@albums = ['http://www.odnoklassniki.ru/profile/123456789123/album/123456789123',
#'http://www.odnoklassniki.ru/profile/123456789123/album/123456789123',
#   ...     'n']

save_images(@tagged, "hcount", 3, "tab-nav_i_txt", "tag") #Saves all the images you were tagged in = На фото друзей 
sleep 1

# Here be dragons ...
@b.close
# Copyright by MEDBEDb @ 2013
# All rights reserved :)