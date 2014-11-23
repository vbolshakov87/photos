class Photo < ActiveRecord::Base

  CONSTANT_123 = 'foo'

 # has_and_belongs_to_many :posts
  has_many :post_photo, class_name: PostPhoto, dependent: :destroy

  has_attached_file :image,
                    :styles => {
                        :medium => '300x300>',
                        :thumb => '100x100>'
                    },
                    :convert_options => {
                        :medium => "-quality 100",
                        :thumb => "-quality 100",
                        :original => "-quality 100"
                    },
                    :default_url => '/images/:style/missing.png'
  validates_attachment_content_type :image, :content_type => /\Aimage\/.*\Z/

  before_create :setTitleBeforeSave

  #scope for post
  scope :fromPost, ->(postId) {
    joins(:post_photo)
  }

  #scope for sorting photos
  scope :sortPhotosAsc, -> { order('sort ASC') }


  include Rails.application.routes.url_helpers

  def to_jq_upload
    {
        'id' => self.id,
        'name' => read_attribute(:image_file_name),
        'size' => read_attribute(:image_file_size),
        'url' => image.url(:original),
        'thumbnail_url' => image.url(:thumb),
        'delete_url' => photo_path(self),
        'delete_type' => 'DELETE'
    }
  end


  def self.bar(a,b)
    return a*b
  end


  def imageFileSize
    helper = Object.new.extend(ActionView::Helpers::NumberHelper)
    helper.number_to_human_size(read_attribute(:image_file_size))
  end


  private
  def setTitleBeforeSave
    if (self.title.to_s.length < 1)
      stops = [".jpeg", ".jpg"]
      self.title = self.image_file_name.gsub(Regexp.union(stops), '')
    end
  end

end