#encoding: UTF-8
require "watir-webdriver"
require "open-uri"
require "watir-webdriver/wait"

def login
 @b = Watir::Browser.new :chrome
 @b.goto "odnoklassniki.ru"
 usr = "TYPE_YOUR_USERNAME"
 pswd = "TYPE_YOUR_PASSWORD"
 @b.text_field(:id, "field_email").set(usr)
 @b.text_field(:id, "field_password").set(pswd)
 @b.input(:id, "hook_FormButton_button_go").click
end

login
@albumURL = "http://url" #Replace URL with following format: http://www.odnoklassniki.ru/profile/012345678901/album/012345678901
@b.goto @albumURL

@ablum_title = @b.span(:class, 'photo-sc_h2_alb-title').text.gsub("\d","").gsub("\/"," ").gsub("?"," ").gsub('"','').to_s[0..230]
@total_number_of_photos_in_album = @b.span(:class, 'photo-sc_h2_alb-count portlet-i_h2_tx').text.split(" ")[0].to_i
@first_image_in_album = @b.img(:class, 'photo-sc_i_cnt_a_img va_target')
@main_image = @b.img(:class, "plp_photo")

@first_image_in_album.click
@main_image.wait_until_present
FileUtils.mkdir_p @ablum_title

for i in 0..@total_number_of_photos_in_album-1 do
@photo_description_title = @b.span(:xpath, "//*[@id='plp_descrCntText']").text.to_s[0..190]
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
    @main_image.wait_until_present
end
@b.close