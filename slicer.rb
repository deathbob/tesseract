require 'fileutils'
require 'rubygems'
require 'RMagick'

# odir this is the path to where the scans are.
odir = 'scans'

files = Dir.entries(odir).reject{|x| !x.match(/SCAN/)}

# ndir this is where you want the ocr of the scans to go
ndir = 'slices_'+ Time.now.to_i.to_s
unless File.exists?(ndir)
  Dir.mkdir(ndir)
end

files = files.first 3

width = 500
height = 500

crops = {
  :ul => [165, 460],
  :ur => [975, 460],
  :bl => [165, 1360],
  :br => [1000, 1360],
}

files.each do |x|
  infile = File.join(odir, x)
  base = File.basename(x, '.tif')
  namefile = File.join("ocrs", base + '.ocr.txt' )
#  puts namefile, File.exists?(namefile)

  clown = Magick::Image::read(infile).first

  crops.each do |k, crop|
    foo = clown.crop(crop[0], crop[1], width, height)
    name = File.join(ndir, base + "_#{k.to_s}" + '.jpg')
    foo.write name
  end
  clown.destroy!

end

