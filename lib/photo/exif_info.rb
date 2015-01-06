class ExifInfo

  attr_accessor :row_data
  attr_accessor :output_data

  def initialize(path)
    self.set_raw_data(path)
    self.output_data = {}
  end

  def set_raw_data(path)
    self.row_data = self.get_raw_exif path
  end

  def get_exif
    if self.output_data.empty?
      self.process_data
    end

    self.output_data
  end

  protected

  @@OUTPUT_FORMAT = [
      :provider,
      :file_name,
      :file_size,
      :image_size,
      :modification_date,
      :access_date,
      :mime_type,
      :make,
      :camera,
      :lens,
      :resolution,
      :software,
      :exposure_time,
      :aperture,
      :iso,
      :exposure,
      :flash,
      :focal_length,
      :focal_length_35,
      :scale_factor,
      :exposure_mode,
      :white_balance,
      :contrast,
      :saturation,
      :sharpness,
      :color_space,
      :quantity
  ]

  def get_raw_exif(path)
  end

  def process_data
  end

end