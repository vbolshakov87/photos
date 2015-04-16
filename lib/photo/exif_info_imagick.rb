class ExifInfoImagick < ExifInfo

  protected

  @@provider = 'imagick'

  @@EXIF_RELEVANT_DATA = [
      'Image',
      'Format',
      'Mime',
      'Geometry',
      'Resolution',
      'Colorspace',
      'Depth',
      'Pixels',
      'Flash',
      'FNumber',
      'Quality',
      'Orientation',
      'DateTime',
      'FocalLength',
      'FocalLengthIn35mmFilm',
      'Make',
      'MaxApertureValue',
      'Model',
      'Software',
      'Created Date[2,55]',
      'Version',
      'ExposureTime',
      'ExposureMode',
      'ISOSpeedRatings',
      'WhiteBalance',
      'Saturation',
      'Sharpness',
      'Contrast',
      'Filesize',
      'Mime type',
      'Rating'
  ]


  def get_raw_exif(path)
    %x(identify -verbose #{path})
  end

  def process_data

    exifRawHash = {}
    exifRaw = self.row_data.split("\n")
    exifRaw.each do |exifString|
      exif_arr = exifString.sub('exif:', '').strip.split(':').collect { |x| x.strip }
      if (@@EXIF_RELEVANT_DATA.include?(exif_arr[0]))
        exifRawHash[exif_arr[0]] = exif_arr[1]
      end
    end

    self.output_data = {}
     @@OUTPUT_FORMAT.each do |key|
      case key
        when :provider
          self.output_data[:provider] = @@provider
        when :file_name
          self.output_data[:file_name] = File.basename(exifRawHash['Image'])
        when :file_size
          self.output_data[:file_size] = exifRawHash['Filesize']
        when :image_size
          self.output_data[:image_size] = exifRawHash['Geometry']
        when :modification_date
          self.output_data[:modification_date] =  exifRawHash['Created Date[2,55]'].to_s.length > 0 ? DateTime.strptime(exifRawHash['Created Date[2,55]'], '%Y%m%d') : ''
        when :access_date
          self.output_data[:access_date] = DateTime.now
        when :mime_type
          self.output_data[:mime_type] = exifRawHash['Mime type']
        when :make
          self.output_data[:make] = exifRawHash['Make']
        when :camera
          self.output_data[:camera] = exifRawHash['Model']
        when :lens
          self.output_data[:lens] = ''
        when :resolution
          self.output_data[:resolution] = exifRawHash['Resolution']
        when :software
          self.output_data[:software] = exifRawHash['Software']
        when :exposure_time
          self.output_data[:exposure_time] = exifRawHash['ExposureTime']
        when :aperture
          self.output_data[:aperture] = exifRawHash['FNumber']
        when :iso
          self.output_data[:iso] = exifRawHash['ISOSpeedRatings']
        when :exposure
          self.output_data[:exposure] = exifRawHash['ExposureTime']
        when :flash
          self.output_data[:flash] = exifRawHash['Flash'].to_i == 1 ? 'Yes' : 'No'
        when :focal_length
          self.output_data[:focal_length] = PhotoHelper::focal_length(exifRawHash['FocalLength']).to_i
        when :focal_length_35
          self.output_data[:focal_length_35] = exifRawHash['FocalLengthIn35mmFilm'].to_i
        when :scale_factor
          self.output_data[:scale_factor] = self.output_data[:focal_length].to_i > 0 && self.output_data[:focal_length_35].to_i > 0 ? (self.output_data[:focal_length_35].to_f/self.output_data[:focal_length].to_f).round(1) : 5
        when :exposure_mode
          self.output_data[:exposure_mode] = exifRawHash['ExposureMode'].to_i == 0 ? 'Auto' : exifRawHash['ExposureMode']
        when :contrast
          self.output_data[:contrast] = exifRawHash['WhiteBalance'].to_i == 0 ? 'Auto' : exifRawHash['WhiteBalance']
        when :saturation
          self.output_data[:saturation] = exifRawHash['Saturation'].to_i == 0 ? 'Normal' : exifRawHash['Saturation']
        when :sharpness
          self.output_data[:sharpness] = exifRawHash['Sharpness'].to_i == 0 ? 'Normal' : exifRawHash['Sharpness']
        when :color_space
          self.output_data[:color_space] = exifRawHash['Colorspace'].to_i == 0 ? 'Normal' : exifRawHash['Colorspace']
        when :quantity
          self.output_data[:quantity] = exifRawHash['Quality']
        when :rating
          self.output_data[:rating] = exifRawHash['Rating'].to_i
      end

    end

    self.output_data

  end

end