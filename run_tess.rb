require 'fileutils'
require 'rubygems'
require 'RMagick'
# odir this is the path to where the scans are.
odir = 'scans'

files = Dir.entries(odir).reject{|x| !x.match(/SCAN/)}

# ndir this is where you want the ocr of the scans to go
ndir = 'ocrs_'+ Time.now.to_i.to_s
unless File.exists?(ndir)
  Dir.mkdir(ndir)
end

files = files.first(4)

files.each_with_index do |x, idx|


  infile = File.join(odir, x)
  clown = Magick::Image::read(infile).first

  foo = clown.crop(1100, 90, 400, 200)
  clown.destroy!

  base = File.basename(x, '.tif')
  subbase = base.gsub(" ", "")
  tmpfile = "tmp/" + base + ".tif"
  foo.write tmpfile
  foo.destroy!


  outfile = File.join(ndir, (subbase + '.ocr'))
  
  puts "\n", outfile, "\n"
  res = system("tesseract #{tmpfile} #{outfile}")
end
