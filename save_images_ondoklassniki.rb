#!/usr/bin/env ruby
#encoding: UTF-8
require "watir-webdriver"
require "open-uri"
require "watir-webdriver/wait"

def get_user_data
  begin
    puts "Вы не ввели данные пользователя или линк к альбому / You did not enter any credentials, or album Url"
    puts "User:" + @usr + " пароль: / password: " + @pswd + " УРЛ: / URL: " + @albumURL
    puts "Введите имя пользователя: / Enter your username: "
    @usr = gets.chomp
    puts "Введите ваш пароль: / Enter your password: "
    @pswd = gets.chomp
    puts "Введите ссылку альбома: / Enter album Url: "
    @albumURL = gets.chomp
  rescue StandardError => e
    print "Error running script: " + e
  end until @usr.size>0 && @pswd.size>0 && @albumURL.size>0
end

def initialize_browser
  @usr = ""
  @pswd = ""
  @albumURL = ""
  @b = Watir::Browser.new :phantomjs #might be :firefox or :chrome, but worth this one
  @b.window.maximize

  if @usr.size>0 && @pswd.size>0 && @albumURL.size>0
    puts "Вы ввели все данные: / Your credentials are set-up: "
    puts "Пользователь / user: " + @usr + " пароль / password: " + "*****" + " УРЛ / URL: " + @albumURL
  else
    get_user_data
  end
end

def login
  puts "\n** Logging in ..."
  @b.goto "odnoklassniki.ru"
  @usr_field = @b.text_field(:id, "field_email")
  @pwd_field = @b.text_field(:id, "field_password")
  @usr_field.when_present.set(@usr)
  @pwd_field.set(@pswd)
  @b.send_keys :enter
  @b.span(:class, "mctc_infoContainer_not_block").wait_until_present
  puts "\n** User Logged In" 
end

def goto_album
  @b.goto @albumURL
end

def get_album_data
  @total_number_of_photos_in_album = @b.span(:class, 'lstp-t').text.gsub(/\D/, "").to_i 
  @first_image_in_album = @b.img(:class, 'photo-sc_i_cnt_a_img va_target')
 end

def delete_a_photo
  @b.i(:class, "ic ic_i ic_i_remove").click
  @b.input(:id, "hook_FormButton_button_delete").when_present.click
  @b.goto @albumURL    
  @b.refresh
end

def create_album_dirrectory
  @ablum_title = @b.div(:class, "photo-sc").span(:class, /h_/).text.to_s[0..155].gsub(/:|\w|<|>|\/|(\d|\/|)|\n|'"'/, "") 
  puts "\n** Making directory ./" + @ablum_title + "\n"
  FileUtils.mkdir_p @ablum_title
end

def save_all_photos_with_descriptions_def
@first_image_in_album = @b.img(:class, 'va_target')
@main_image = @b.img(:class, "photo-layer_img rotate__0deg")
@first_image_in_album.when_present.click

for i in 1..@total_number_of_photos_in_album do
sleep 0.1
@main_image.wait_until_present
@photo_description_title = "" #
  if @b.span(:id => "plp_descrCntText").exists?
      @photo_description_title = @b.span(:id => "plp_descrCntText").text.gsub(/:|\w|<|>|\/|(\d|\/|)|'"'/, "")
      File.open((@ablum_title.to_s + "/" + i.to_s + " " + @photo_description_title).strip.to_s[0..255] + ".jpg", 'wb') do |f|
      f.write open(@main_image.src).read
      puts "Saving img " + i.to_s + " and title: " + @photo_description_title
      end
  else 
      File.open(@ablum_title.to_s + "/" + i.to_s + " " + @ablum_title.to_s + ".jpg", 'wb') do |f|
      f.write open(@main_image.src).read
      puts "Saving img " + i.to_s + " and title: " + @ablum_title.to_s
      end
  end
  @b.span(:class => "arw_ic", :index => 1).click
 end
end

def terminate
  puts "\n" + @total_number_of_photos_in_album.to_s + " photos saved in ./" + @ablum_title + " folder\n\n"
  @b.close
end

initialize_browser
login
goto_album
get_album_data
create_album_dirrectory
save_all_photos_with_descriptions_def
terminate

#TBU: add captcha finder when opening 200+ photos and decaptcha using tesseract
