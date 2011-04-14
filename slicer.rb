require 'fileutils'
require 'rubygems'
require 'RMagick'

# odir this is the path to where the scans are
# This is where the scans you want sliced up reside.
#odir = 'scans'
odir = 'scans_missing'

line_number = '25'



# ndir this is where you want the ocr of the scans to go
ndir = 'slices_'+ Time.now.to_i.to_s #+ "_shifted_left"
unless File.exists?(ndir)
  Dir.mkdir(ndir)
end
x_shift = 0
y_shift = 0









files = Dir.entries(odir).reject{|x| !x.match(/SCAN/)}

#files = [files[27]]
#files = files.first 40

width =  500 - 50
height = 500 - 50



crops = {
  '1' => [185,   490],
  '2' => [1010,  490],
  '3' => [185,  1390],
  '4' => [1010, 1390],
}

# PS are about 750 w by 380 h
ps_crops = {
  '1' => [455, 340],
  '2' => [455, 850],
  '3' => [455, 1350],
  '4' => [455, 1850],
}
ps_width  = 700
ps_height = 370

name_scan = {}
previous_name = ''

#files = files.sort{|a, b| a.length <=> b.length}



puts files.inspect
files.each do |x|
  infile = File.join(odir, x)
  base = File.basename(x, '.tif')
  subbase = base.gsub(" ", "")

  # Stuff to find the name of the slices
  # You will need to have a folder in the directory which you are running this program from, called 'ocrs'
  # In that folder will need to be a bunch of files that correspond to the scans you made, each containing the text of the name of the line that is in question.
  namefile = File.join("ocrs", subbase + '.ocr.txt' )
  unless File.exists?(namefile)
    # if you're getting this you probably haven't run run_tess.rb
    raise NameFileMissing
  end
  names = File.readlines(namefile, 'r')
  re = /.*(#{line_number}.*)/m
  mat = names.detect{|y| y.match(re)}
  name = 'whoops'
  if mat
    name = mat.match(re)[1].gsub(/[^\w]/, '')
  else
    puts "Problem in #{infile}, couldn't extract name, skipping to next"
    next
  end
  puts name

  name_scan[name] = x
#  puts name_scan.inspect

  style = crops
  w = width
  h = height
  # Logic to determine if this is a pocket square or a regular tie swatch
  is_pocket_square = (name.match('PS') && (name.length > 4)) ? true : false
  if is_pocket_square
    style = ps_crops
    w = ps_width
    h = ps_height
  end


  # actually do the slicing
  clown = Magick::Image::read(infile).first

  style.each do |k, crop|
    foo = clown.crop(crop[0] + x_shift, crop[1] + y_shift, w, h)
    ## resize if pocket square
    if is_pocket_square
      foo.change_geometry!('500x500>') { |cols, rows, img|
        img.resize!(cols, rows)
      }
    else
      foo.change_geometry!('500x500!'){ |cols, rows, img|
        img.resize!(cols, rows)
      }
    end

    # build name
    num = k.to_i
    num += 4 if (previous_name == name)

    bar = File.join(ndir, "PB" + name + "-#{num}" + '.jpg')
    foo.write bar
  end
  clown.destroy!

  previous_name = name
end



