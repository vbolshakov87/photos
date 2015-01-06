module PhotoHelper

  def self.focal_length(stringLength)
    stringLength = stringLength.to_s
    data = stringLength.split("/")
    if (data.length == 2)
      return (data[0].to_i / data[1].to_i).round
    else
      return stringLength
    end
  end
end