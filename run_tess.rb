require 'fileutils'
require 'rubygems'
require 'RMagick'
require 'peter_blair'

##############################################################################################
######### This Runs the Tesseract program on the Scans.
# The scans need to be in .tiff format.
# The Tesseract Program is an OCR (Optical Character Recognition) program.
# I use it to extract the code of the item which is in the .tiff, so that we can later rename and slice these .tiffs with the slicer.rb program
####################################################################################################



# odir this is the path to where the scans are.
#odir = 'scans'
odir = 'scans_missing'

# ndir this is where you want the ocr of the scans to go
# Defaults to a new directory in the directory you run this from, named ocrs_1231231231 or similar.  number portion determined by unix epoch
ndir = 'ocrs_'+ Time.now.to_i.to_s




# It is unlikely that you need to edit anything below this line.
###########################################################################################################################################################
###########################################################################################################################################################\n
###########################################################################################################################################################
# Only grab files with the word SCAN in the name.
# This means that when you're scanning them in with Preview or whatever, you need to make sure they're being saved with the word SCAN in the name.
files = Dir.entries(odir).reject{|x| !x.match(/SCAN/i)}


unless File.exists?(ndir)
  Dir.mkdir(ndir)
end

# tmp is for i don't know what.
Dir.mkdir('tmp') unless File.exists?('tmp')

# PeterBlair.new(
#   :scan_dir => 'scans',
#   :line_number => "25",
#   :ocr_dir => 'slices_' + Time.now.to_i.to_s
# )
#
# raise EndHere

# Loop through the scans and extract the code, something like PB25ANPS or PB2501
files.each_with_index do |x, idx|

  infile = File.join(odir, x)
  clown = Magick::Image::read(infile).first

  foo = clown.crop(1100, 10, 420, 330)
  # If you don't destroy the image, your RAM usage will go thru the roof.  Don't blame me if you chew up 4gigs of ram or more.
  clown.destroy!

  base = File.basename(x, '.tif')
  subbase = base.gsub(" ", "")
  tmpfile = "tmp/" + subbase + ".tif"
  foo.write tmpfile
  foo.destroy!

  outfile = File.join(ndir, (subbase + '.ocr'))

  # Here's where we actually call tesseract, passing it the name of the tempfile which is a crop of the original file,
  # and the new file where it writes the characters it is able to extract.
  res = system("tesseract #{tmpfile} #{outfile}")
end

