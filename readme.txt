make a new service in automator

add "rotate images", rotate to left, if necessary

add 'change image type' to tiff, if necessary.

Run this service on the files you plan to OCR.  (as a service you can just select all and right click to run it.)

Install tesseract.  Build from source, works fine with 3.0.0 on Mac OS X 10.6.7

Add the english language pack (eng.traineddata) to tesseract.  Put in in /usr/local/share/tessdata/

Edit and run tmp.rb to use SliceDice on your images.


TODO make the crop selection be proportional instead of pixel based, so it works on scans of any DPI.
I promise figuring out how to run this on the image scans will be faster than doing it by hand, take bit and sort it out.
 tmp.rb is a good start.
crops is the x and y coordinates of the upper left corner of the square that will be cropped, adjust this accordingly to
crop each of the 4 images out of the scan.
alt_crops is the x and y coordinates for pocket square images, which have a different layout than the rest.

scan_dir is the directory where the images you want to crop and rename live.

line_number is the line designated by peter blair that you are importing.  Used as a prefix both in the website and for images.
crops is crops, alt_crops are alt_crops.  not sure why I made this configurable.

I suggest just populating a directory appropriately with images and running the program, the results should guide you on
what needs to be tweeked