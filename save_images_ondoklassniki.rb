#encoding: UTF-8
require "watir-webdriver"
require "open-uri"
require "watir-webdriver/wait"

def login
 @b = Watir::Browser.new :firefox #might be :chrome, but worth this one
 @b.goto "odnoklassniki.ru"
 usr = "TYPE_YOUR_USERNAME"
 pswd = "TYPE_YOUR_PASSWORD"
 @b.text_field(:id, "field_email").when_present.set(usr)
 @b.text_field(:id, "field_password").set(pswd)
 @@b.send_keys :enter
end

puts "\n** Logging in ..."
login
@albumURL = "URL" #Replace URL with following format: http://www.odnoklassniki.ru/profile/012345678901/album/012345678901
@b.goto @albumURL
puts "...ok, going in Album"

@ablum_title = @b.span(:class, 'photo-sc_h2_alb-title').text.gsub("\d","").gsub("\/"," ").gsub("?"," ").gsub('"','').to_s[0..255]
puts "\n** Making directory ./" + @ablum_title + "\n"
FileUtils.mkdir_p @ablum_title

#Replace non integer symbols if number of photos over than 999, f.e. "12 345"
@total_number_of_photos_in_album = @b.span(:class, 'photo-sc_h2_alb-count portlet-i_h2_tx').text.gsub(/\D/, "").to_i 

@first_image_in_album = @b.img(:class, 'photo-sc_i_cnt_a_img va_target')
@main_image = @b.img(:class, "plp_photo")

for i in 1..@total_number_of_photos_in_album do

@first_image_in_album.when_present.click
@main_image.wait_until_present
@photo_description_title = @b.span(:xpath, "//*[@id='plp_descrCntText']").text.to_s[0..255]

  if @photo_description_title.size == 0
      File.open(@ablum_title.to_s + "/" + i.to_s + " " + @ablum_title.to_s + ".jpg", 'wb') do |f|
      f.write open(@main_image.src).read
      puts "Saving img " + i.to_s + " and title: " + @ablum_title.to_s
      end
  elsif @photo_description_title.size > 0
      File.open(@ablum_title.to_s + "/" + i.to_s + " " + @photo_description_title.gsub("\d","").gsub("\/"," ").gsub("?"," ").gsub('"','') + ".jpg", 'wb') do |f|
      f.write open(@main_image.src).read
      puts "Saving img " + i.to_s + " and title: " + @photo_description_title
      end
  end
  
@b.div(:id, "plp_slide_r").click #clicking next button
#### if you want at once to delete all photos in Album, then remove (or #comment) line 50 above
#### and UNcomment four lines[53..56] below :
# @b.i(:class, "ic ic_i ic_i_remove").click
# @b.input(:id, "hook_FormButton_button_delete").when_present.click
# @b.goto @albumURL    
# @b.refresh
####
####
end
puts "\n" + @total_number_of_photos_in_album.to_s + " photos saved in ./" + @ablum_title + " folder\n\n"
@b.close
