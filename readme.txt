make a new service in automator

add "rotate images", rotate to left, if necessary

add 'change image type' to tiff, if necessary.

Run this service on the files you plan to OCR.  (as a service you can just select all and right click to run it.)

Install tesseract.  Build from source, works fine with 3.0.0 on Mac OS X 10.6.7

Add the english language pack (eng.traineddata) to tesseract.  Put in in /usr/local/share/tessdata/

Edit and run tmp.rb to use SliceDice on your images.

