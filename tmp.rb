require 'slice_dice'


crops = {
  '1' => [185,   490],
  '2' => [1010,  490],
  '3' => [185,  1390],
  '4' => [1010, 1390],
}


alt_crops = {
  '1' => [455, 340],
  '2' => [455, 850],
  '3' => [455, 1350],
  '4' => [455, 1850],
}
pete = SliceDice.new(
  :scan_dir =>    'scans_missing',
  :line_number => '25',
  :crops => crops,
  :alt_crops => alt_crops
)

pete.extract_product_codes
pete.slice_images