require 'fileutils'
require 'rubygems'
require 'RMagick'

class SliceDice

  attr_accessor :scan_dir, :scan_file_names, :line_number, :ocr_dir, :slice_dir, :x_shift, :y_shift, :crops, :alt_crops
  sizes = [:slice_width, :slice_height, :alt_slice_width, :alt_slice_height]
  attr_accessor *sizes

  def initialize(options = {})
    @time = Time.now.to_i.to_s

    # Directory where the image files you are going to OCR live.
    # They need to be in .tif format and read left to right.
    # That means you need to rotate the image if the text doesn't run left to right after scanning them in.
    @scan_dir = options[:scan_dir] || "scans"

    # Line Number, for internal purposes, safe to ignore.
    @line_number = options[:line_number] || '25'

    # Directory where the files that result from the slicing process will be put
    @slice_dir = "#{scan_dir}_SLICES_" + @time
    Dir.mkdir(@slice_dir)  unless File.exists?(@slice_dir)

    # Directory where the files that result from the OCR process will be put.
    @ocr_dir = "#{@scan_dir}_OCR_"    + @time
    Dir.mkdir(@ocr_dir)    unless File.exists?(@ocr_dir)

    # Only grab files with the word SCAN in the name.
    # This means that when you're scanning them in with Preview or whatever, you need to make sure they're being saved with the word SCAN in the name.
    @scan_file_names = Dir.entries(@scan_dir).reject{|x| !x.match(/SCAN/)}

    # tmp is where the crops of the full size images are stored.
    # It can safely be blown away between runs.
    Dir.mkdir('tmp') unless File.exists?('tmp')


    @x_shift = options[:x_shift] || 0
    @y_shift = options[:y_shift] || 0

    @slice_width =           options[:slice_width] || 450
    @slice_height =         options[:slice_height] || 450
    @alt_slice_width =  options[:alt_slice_height] || 700
    @alt_slice_height = options[:alt_slice_height] || 370

    # should raise error if at minimum options[:crops] is not passed
    @crops = options[:crops]
    @alt_crops = options[:alt_crops]
  end


  def extract_product_codes
    # Loop through the scans and extract the code, something like PB25ANPS or PB2501
    @scan_file_names.each do |fname|
      infile = File.join(@scan_dir, fname)
      clown = Magick::Image::read(infile).first

      # this crop call grabs the pixels starting at 1100 (x), 10 (y), in a box size of 420 (x), 330 (y)
      foo = clown.crop(1100, 10, 420, 330)
      # If you don't destroy the image, your RAM usage will go thru the roof.  Don't blame me if you chew up 4gigs of ram or more.
      clown.destroy!

      base = File.basename(fname, '.*')
      subbase = base.gsub(" ", "")
      tmpfile = "tmp/" + subbase + ".tif"
      foo.write tmpfile
      foo.destroy!

      outfile = File.join(@ocr_dir, (subbase + '.ocr'))

      # Here's where we actually call tesseract, passing it the name of the tempfile which is a crop of the original file,
      # and the new file where it writes the characters it is able to extract.
      res = system("tesseract #{tmpfile} #{outfile}")
    end
  end


  # Must have run extract_product_codes first.
  def slice_images
    name_scan = {}
    previous_name = ''

    @scan_file_names.each do |fname|
      puts fname
      infile = File.join(@scan_dir, fname)
      base = File.basename(fname, '.*')
      subbase = base.gsub(" ", "")

      name = extract_product_code(subbase)
      puts "\t#{name}"
      name_scan[name] = fname

      # Logic to determine if this is a pocket square or a regular tie swatch
      is_pocket_square = (name.match('PS') && (name.length > 4)) ? true : false
      if is_pocket_square
        style = @alt_crops
        w = @alt_slice_width
        h = @alt_slice_height
      else
        style = @crops
        w = @slice_width
        h = @slice_height
      end

      # actually do the slicing
      clown = Magick::Image::read(infile).first

      style.each do |k, crop|
        foo = clown.crop(crop[0] + @x_shift, crop[1] + @y_shift, w, h)
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

        # build new name, format of PB-25ANPS-1.jpg, PB-25ANPS-2.jpg
        num = k.to_i
        num += 4 if (previous_name == name)

        bar = File.join(@slice_dir, "PB" + name + "-#{num}" + '.jpg')
        puts "\t\t#{File.basename(bar)}"
        foo.write bar
      end
      clown.destroy!

      previous_name = name
    end

  end


  # Stuff to find the name of the slices
  # You will need to have a folder in the directory which you are running this program from, called 'ocrs'
  # In that folder will need to be a bunch of files that correspond to the scans you made,
  #   each containing the text of the name of the line that is in question.
  def extract_product_code(subbase)
    re = /.*(#{@line_number}.*)/m

    namefile = File.join(@ocr_dir, subbase + '.ocr.txt' )
    unless File.exists?(namefile)
      # if you're getting this you probably haven't run extract_product_codes
      raise "NameFileMissing"
    end
    names = File.readlines(namefile, 'r')

    mat = names.detect{|y| y.match(re)}
    if mat
      name = mat.match(re)[1].gsub(/[^\w]/, '')
    else
      puts "Problem in #{infile}, couldn't extract name, skipping to next"
      next
    end
    return name
  end

end