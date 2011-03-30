require 'fileutils'
require 'rubygems'
require 'RMagick'

# odir this is the path to where the scans are.
odir = 'scans'
line_number = '25'

files = Dir.entries(odir).reject{|x| !x.match(/SCAN/)}

# ndir this is where you want the ocr of the scans to go
ndir = 'slices_'+ Time.now.to_i.to_s
unless File.exists?(ndir)
  Dir.mkdir(ndir)
end

#files = [files[27]]
files = files.first 40

width = 500
height = 500

crops = {
  '1' => [165, 460],
  '2' => [975, 460],
  '3' => [165, 1360],
  '4' => [1000, 1360],
}

# PS are about 750 w by 380 h
ps_crops = {
  '1' => [445, 340],
  '2' => [445, 850],
  '3' => [445, 1350],
  '4' => [445, 1850],
}
ps_width  = 740
ps_height = 390

name_scan = {}
previous_name = ''

puts files.inspect
files = files.sort{|a, b| a.length <=> b.length}
puts files.inspect

files.each do |x|
  infile = File.join(odir, x)
  base = File.basename(x, '.tif')
  subbase = base.gsub(" ", "")



# Stuff to find the name of the slices
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
  is_pocket_square = name.match('PS') ? true : false
  if is_pocket_square
    style = ps_crops
    w = ps_width
    h = ps_height
  end


  # actually do the slicing
  clown = Magick::Image::read(infile).first

  style.each do |k, crop|
    foo = clown.crop(crop[0], crop[1], w, h)
    # resize if ps
    # if is_pocket_square
    #   foo.change_geometry!('500x500>') { |cols, rows, img|
    #     img.resize!(cols, rows)
    #   }
    # end

    # build name
    num = k.to_i
    num += 4 if (previous_name == name)

    bar = File.join(ndir, "PB" + name + "-#{num}" + '.jpg')
    foo.write bar
  end
  clown.destroy!

  previous_name = name
end



