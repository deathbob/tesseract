require 'fileutils'
require 'rubygems'
require 'RMagick'

class PeterBlair

  attr_accessor :scan_dir, :scan_file_names, :line_number, :ocr_dir

  def initialize(options = {})
    @scan_dir = options[:scan_dir] || "scans"
    @line_number = options[:line_number] || '25'
    @scan_file_names = Dir.entries(@scan_dir).reject{|x| !x.match(/SCAN/)}
    @ocr_dir = options[:ocr_dir] || ('slices_' + Time.now.to_i.to_s)
    Dir.mkdir(@ocr_dir)    unless File.exists?(@ocr_dir)
  end
end