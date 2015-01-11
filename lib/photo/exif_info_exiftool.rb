class ExifInfoExiftool < ExifInfo

  protected

  @@provider = 'exiftool'

  @@EXIF_RELEVANT_DATA = [
      'File Name',
      'File Size',
      'File Modification Date/Time',
      'File Access Date/Time',
      'MIME Type',
      'Make',
      'Camera Model Name',
      'X Resolution',
      'Y Resolution',
      'Software',
      'Exposure Time',
      'Aperture',
      'ISO',
      'Flash',
      'Focal Length',
      'Exposure Mode',
      'White Balance',
      'Digital Zoom Ratio',
      'Focal Length',
      'Upright Focal Length 35mm',
      'Scale Factor To 35 mm Equivalent',
      'Contrast',
      'Saturation',
      'Sharpness',
      'Lens',
      'Device Model',
      'Image Size',
      'Lens ID',
      'Lens Profile Name',
  ]


  def get_raw_exif(path)
    %x(exiftool #{path})
  end

  def process_data

    exifRawHash = {}
    exifRaw = self.row_data.split("\n")
    exifRaw.each do |exifString|
      exif_arr = exifString.strip.split(': ').collect { |x| x.strip }
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
          self.output_data[:file_name] = exifRawHash['File Name']
        when :file_size
          self.output_data[:file_size] = exifRawHash['File Size']
        when :image_size
          self.output_data[:image_size] = exifRawHash['Image Size']
        when :modification_date
          self.output_data[:modification_date] =  exifRawHash['File Modification Date/Time']
        when :access_date
          self.output_data[:access_date] = DateTime.now
        when :mime_type
          self.output_data[:mime_type] = exifRawHash['MIME Type']
        when :make
          self.output_data[:make] = exifRawHash['Make']
        when :camera
          self.output_data[:camera] = exifRawHash['Camera Model Name']
        when :lens
          self.output_data[:lens] = exifRawHash['Lens ID']
        when :resolution
          self.output_data[:resolution] = exifRawHash['X Resolution'].to_s + 'x' + exifRawHash['Y Resolution'].to_s
        when :software
          self.output_data[:software] = exifRawHash['Software']
        when :exposure_time
          self.output_data[:exposure_time] = exifRawHash['Exposure Time']
        when :aperture
          self.output_data[:aperture] = exifRawHash['Aperture']
        when :iso
          self.output_data[:iso] = exifRawHash['ISO']
        when :exposure
          self.output_data[:exposure] = exifRawHash['Exposure Mode']
        when :flash
          self.output_data[:flash] = exifRawHash['Flash']
        when :focal_length
          self.output_data[:focal_length] = exifRawHash['Focal Length'].to_i
        when :focal_length_35
          self.output_data[:focal_length_35] = exifRawHash['Upright Focal Length 35mm'].to_i
        when :scale_factor
          self.output_data[:scale_factor] = exifRawHash['Scale Factor To 35 mm Equivalent'].to_f
        when :exposure_mode
          self.output_data[:exposure_mode] = exifRawHash['Exposure Mode']
        when :contrast
          self.output_data[:contrast] = exifRawHash['White Balance']
        when :saturation
          self.output_data[:saturation] = exifRawHash['Saturation']
        when :sharpness
          self.output_data[:sharpness] = exifRawHash['Sharpness']
        when :color_space
          self.output_data[:color_space] = exifRawHash['Device Model']
        when :quantity
          self.output_data[:quantity] = 100
      end

    end

    self.output_data

  end

end