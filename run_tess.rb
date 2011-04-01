require 'fileutils'
require 'rubygems'
require 'RMagick'
require 'peter_blair'




# odir this is the path to where the scans are.
odir = 'scans'

files = Dir.entries(odir).reject{|x| !x.match(/SCAN/)}

# ndir this is where you want the ocr of the scans to go
ndir = 'ocrs_'+ Time.now.to_i.to_s
unless File.exists?(ndir)
  Dir.mkdir(ndir)
end

Dir.mkdir('tmp') unless File.exists?('tmp')

PeterBlair.new(
  :scan_dir => 'scans',
  :line_number => "25",
  :ocr_dir => 'slices_' + Time.now.to_i.to_s
)

raise EndHere



# Pocket squares start at SCAN 119

files.each_with_index do |x, idx|


  infile = File.join(odir, x)
  clown = Magick::Image::read(infile).first

  foo = clown.crop(1100, 10, 420, 330)
  clown.destroy!

  base = File.basename(x, '.tif')
  subbase = base.gsub(" ", "")
  tmpfile = "tmp/" + subbase + ".tif"
  foo.write tmpfile
  foo.destroy!


  outfile = File.join(ndir, (subbase + '.ocr'))

  res = system("tesseract #{tmpfile} #{outfile}")
end

