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
  #test alubmURL http://www.odnoklassniki.ru/tripdiary/album/52156897755216
  @b = Watir::Browser.new :firefox #might be :chrome, but worth this one
  if @usr.size>0 && @pswd.size>0 && @albumURL.size>0
    puts "Вы ввели все данные: / Your credentials are set-up: "
    puts "Пользователь / user: " + @usr + " пароль / password: " + @pswd + " УРЛ / URL: " + @albumURL
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
  #@b.send_keys :enter
  @b.input(:class, "button-pro button-pro_big anonym_login_btn inlineBlock").click
  @b.span(:id, "portal-headline_login").wait_until_present
end

def goto_album
  @b.goto @albumURL
end

def get_album_data
  @total_number_of_photos_in_album = @b.span(:class, 'photo-sc_h2_alb-count portlet-i_h2_tx').text.gsub(/\D/, "").to_i 
  @first_image_in_album = @b.img(:class, 'photo-sc_i_cnt_a_img va_target')
  @main_image = @b.img(:class, "plp_photo") #can be deleted
 end

def delete_a_photo
  @b.i(:class, "ic ic_i ic_i_remove").click
  @b.input(:id, "hook_FormButton_button_delete").when_present.click
  @b.goto @albumURL    
  @b.refresh
end

def create_album_dirrectory
  @ablum_title = @b.span(:class, 'photo-sc_h2_alb-title').text.gsub("\d","").gsub("\/"," ").gsub("?"," ").gsub('"','').to_s[0..255]
  puts "\n** Making directory ./" + @ablum_title + "\n"
  FileUtils.mkdir_p @ablum_title
end

def save_all_photos_enumerated_with_no_descriptions
  @first_image_in_album = @b.img(:class, 'photo-sc_i_cnt_a_img va_target')
  $main_image = @b.img(:class, "plp_photo")

  @first_image_in_album.when_present.click
  for i in 1..@total_number_of_photos_in_album do
    sleep 0.2
    $main_image.wait_until_present
      File.open(@ablum_title.to_s + "/" + i.to_s + ".jpg", 'wb') do |f|
      f.write open($main_image.src).read
      puts "Saving file number " + i.to_s + " and title: " + @ablum_title.to_s
      end
  @b.div(:id, "plp_slide_r").when_present.click #clicking next button
  end
end


def save_all_photos_with_descriptions_def
@first_image_in_album = @b.img(:class, 'photo-sc_i_cnt_a_img va_target')
@main_image = @b.img(:class, "plp_photo")
@first_image_in_album.when_present.click

for i in 1..@total_number_of_photos_in_album do
sleep 0.2
@main_image.wait_until_present
@photo_description_title = @b.span(:id => "plp_descrCntText", :class => "plp_descrCntText").text.to_s[0..255].gsub(/(\d|\/|)|\w/, "").gsub("\n","").gsub('"','')
  if @photo_description_title.size == 0
      File.open(@ablum_title.to_s + "/" + i.to_s + " " + @ablum_title.to_s + ".jpg", 'wb') do |f|
      f.write open(@main_image.src).read
      puts "Saving img " + i.to_s + " and title: " + @ablum_title.to_s
      end
  elsif @photo_description_title.size > 0
      File.open(@ablum_title.to_s + "/" + i.to_s + " " + @photo_description_title + ".jpg", 'wb') do |f|
      f.write open(@main_image.src).read
      puts "Saving img " + i.to_s + " and title: " + @photo_description_title
      end
  end
 @b.div(:id, "plp_slide_r").hover
 @b.div(:id, "plp_slide_r").when_present.click #clicking next button
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
#save_all_photos_enumerated_with_no_descriptions
terminate

#TBU: add captcha finder when opening 200+ photos and decaptcha using tesseract