save_images_ondoklassniki
=========================

A ruby + watir-webdriver script that will save all images from any given album from ondoklassniki.ru

Instructions: 
Make sure you have firefox installed and your ruby version is =< 2.0
Install "watir-webdriver" (gem install watir-webdriver)
Add latest PhantomJS binary to your path http://phantomjs.org/download.html

Steps:

1. Fork or clone the repo.

2. Add your username to line: 23
  @usr = "youruser"

   Add your password to line: 24
  @pswd = "yourpassword"

   Add album URL to line: 25
  @albumURL = "http://odnoklassniki.ru/page/album/12345678901234567" 

3. Run 'ruby save_images_ondoklassniki.rb'

All images are saved into newly generated dirrectory which matches the album name.
After the script finishes running open your folder full with all your graphic files. Now you're good to go :)


P.S.> Feel free to play with it, and send me a pull request if implemented something new && util xD



Video demonstration of script working can be found here:
=========================
https://www.youtube.com/watch?v=dnkgBgUpU60

Old: https://www.youtube.com/watch?v=JK2VFZkMXRQ



Copyright (c) 2013 MEDBEDb.
=========================
Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
