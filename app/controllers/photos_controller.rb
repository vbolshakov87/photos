class PhotosController < ApplicationController
  before_action :set_photo, only: [:show, :edit, :update, :destroy]

  # GET /photos
  def index
    getPhotosWithFilter
  end

  def filter
    getPhotosWithFilter
    @show_filter = true
    render partial: 'photo_list', formats: :html
  end

  # GET /photos/1
  # GET /photos/1.json
  def show
  end

  def forpost
    postId = params[:post]
    if (!postId)
      raise 'there is no post in in input params'
    end

    @photos = Photo.sortPhotosAsc.fromPost(postId).all
    @post = Post.find(postId);

    respond_to do |format|
      format.html
      format.json { render json: @photos.map{|photo| photo.to_jq_upload } }
    end
  end

  def post_gallery_ajax
    postId = params[:post]
    if (!postId)
      raise 'there is no post in in input params'
    end

    @photos = Photo.sortPhotosAsc.fromPost(postId).all
    render partial: 'post_gallery_ajax', formats: :html
  end


  def popup
    photoId = params[:photo]
    if (!photoId)
      raise 'there is no post in in input params'
    end

    @photo = Photo.find(photoId)
    @posts = Post.joins(:posts_photos).where('posts_photos.photo_id = ?', photoId)

    tags = @photo.tags.any? ?  @photo.tags : @posts[0].tags
    @tagsArr = Array.new
    tags.each do |tag|
      @tagsArr.push(tag.title)
    end

    @postArr = Array.new
    @posts.each do |post|
      @postArr.push(ApplicationHelper::Post.post_autocomplite_title(post))
    end

    #default values
    @photo.geo_latitude = @photo.geo_latitude.present? ? @photo.geo_latitude : (@posts[0].present? ? @posts[0].geo_latitude : Rails.application.config.default_geo_latitude )
    @photo.geo_longitude = @photo.geo_longitude.present? ? @photo.geo_longitude : (@posts[0].present? ? @posts[0].geo_longitude : Rails.application.config.default_geo_longitude )
    @exif = ActiveSupport::JSON.decode(@photo.exif)
    render partial: 'popup', formats: :html
  end

  def exif
    photoId = params[:photo]
    if (!photoId)
      raise 'there is no post in in input params'
    end

    photo = Photo.find(photoId)
    path = Rails.root + photo.image.path(:original)

    @exifRawHash = {}
    exifRaw = %x(identify -verbose #{path}).split("\n")
    exifRaw.each do |exifString|
      exifArr = exifString.sub('exif:', '').strip.split(':').collect { |x| x.strip }
      #if (['Image', 'Format', 'Mime', 'Geometry', 'Resolution', 'Colorspace', 'Depth', 'Pixels', 'Quality', 'Orientation', 'DateTime', 'FocalLength', 'FocalLengthIn35mmFilm', 'Make', 'MaxApertureValue', 'Model', 'Software', 'Created Date[2,55]', 'Version'].include?(exifArr[0]))
        @exifRawHash[exifArr[0]] = exifArr[1]
      #end
      #render :text => exifArr
      #break
    end
  end

  # sort images
  def sort
    postId = params[:post]
    sorted = params[:sorted].uniq

    # get ids from the DB
    existValues = Photo.where('`photos`.`id` IN (?)', sorted).fromPost(postId).select('photos.id').all.to_a
    # cj=heck by count
    if (existValues.length != sorted.length)
      raise 'error in images count'
    end
    #check by each id
    existValuesHash = {}
    existValues.each do |value|
     existValuesHash[value.id.to_i] = true
    end

    sorted.each do |value|
      value = value.to_i
      if (existValuesHash.has_key?(value))
        existValuesHash.delete(value)
      else
        raise "error photo id=#{value} does not exist in a post #{postId}"
      end
    end


    if (existValuesHash.length > 0)
      raise 'not all the images from post set to be sorted'
    end

    # build the sql query
    sqlCode = "INSERT INTO `#{Photo.table_name}` (id,sort) VALUES"
    values = []
    sorted.each_with_index do |id, index|
      sort = (index+1)*100
      values.push "(#{id},#{sort})"
    end
    sqlCode += values.join(',').to_s + 'ON DUPLICATE KEY UPDATE sort=VALUES(sort);'

    ActiveRecord::Base.connection.execute(sqlCode)

    render :json => {success: true} and return
  end

  # GET /photos/new
  def new
    @photo = Photo.new
  end

  # GET /photos/1/edit
  def edit

  end


  # POST /uploads
  # POST /uploads.json
  def create

    p_attr = params[:photo]
    p_attr.permit!
    @photo = Photo.new(p_attr)

    respond_to do |format|
      if @photo.save
        #save new link between photo and post
        if (params[:post_id].length)

          countInPost = PostPhoto.where(post_id: params[:post_id]).count
          @photo.sort = (countInPost+1)*100
          @photo.save

          #check post
          post = Post.find(params[:post_id])
          if (!post.present?)
            raise 'Post is not found'
          end

          if (post.main_photo.to_i < 1)
            post.main_photo = @photo.id
            post.save
          end

          @postPhoto = PostPhoto.find_or_initialize_by(post_id: params[:post_id], photo_id: @photo.id)
          @postPhoto.save

        end

        format.html {
          render :json => [@photo.to_jq_upload].to_json,
                 :content_type => 'text/html',
                 :layout => false
        }
        format.json { render json: {files: [@photo.to_jq_upload]}, status: :created, location: @photo }
      else
        format.html { render action: "new" }
        format.json { render json: @photo.errors, status: :unprocessable_entity }
      end
    end
  end


  # PATCH/PUT /photos/1
  # PATCH/PUT /photos/1.json
  def update
    # myParams = photo_params
    respond_to do |format|
      if @photo.update(photo_params)

        # save tags
        save_tags true

        PostPhoto.delete_all(photo_id: @photo.id)
        if (params[:posts].length > 0)
          posts = params[:posts].split(',').uniq
          posts.each do |postId|
            postPhoto = PostPhoto.find_or_initialize_by(post_id: postId, photo_id: @photo.id)
            postPhoto.save
          end
        end

        format.html { redirect_to @photo, notice: 'Photo was successfully updated.' }
        format.json {
          render json: {
            status: :ok,
            photo: @photo
          }
        }
      else
        format.html { render :edit }
        format.json {
          render json: {
              errors => @photo.errors,
              status => :error
          },
          status: :unprocessable_entity
        }
      end
    end
  end


  # DELETE /photos/1
  # DELETE /photos/1.json
  def destroy
    #remove main photo if necessary
    post = Post.where(main_photo: @photo.id).first
    if (post.present?)
      firstPhoto = Photo.sortPhotosAsc.fromPost(post.id).first
      if (firstPhoto.present?)
        post.main_photo = firstPhoto.id
        post.save
      end
    end

    @photo.destroy

    respond_to do |format|
      format.html { redirect_to photos_url, notice: 'Photo was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

    def getPhotosWithFilter
      photoRecord = Photo

      @sort = {
          :created_at => 'desc'
      }
      if (params[:sort].present?)
        @sort = params[:sort]
      end

      #counts
      photoRecord = photoRecord.select('photos.*').joins('LEFT JOIN posts_photos ON posts_photos.photo_id = photos.id').joins('LEFT JOIN posts ON posts_photos.post_id = posts.id')

      if (params[:filter].present?)
        #by name
        photoRecord = photoRecord.byName(params[:filter][:name])

        # by tags
        if (params[:filter].present? && params[:filter][:tags].present?)
          tags = params[:filter][:tags].split(',').uniq
          photoRecord = photoRecord.joins(:tags)
          photoRecord = photoRecord.where('tags.title IN (?)', tags)
        end

        # by dates
        if (params[:filter][:date_from].to_s.length > 0)
          photoRecord = photoRecord.where('posts.date_from >= ?',  DateTime.strptime(params[:filter][:date_from], '%d/%m/%Y'))
        end
        if (params[:filter][:date_to].to_s.length > 0)
          photoRecord = photoRecord.where('posts.date_to <= ?',  DateTime.strptime(params[:filter][:date_to], '%d/%m/%Y'))
        end
      end

      @sort.each do |column,direction|
        photoRecord = photoRecord.order(column.to_s + ' ' + direction.to_s)
      end

      # paging
      @perPage = 4
      if (cookies[:photo_per_page].present?)
        @perPage = cookies[:photo_per_page];
      end
      if (params[:per_page].present? && params[:per_page].to_i > 0)
        @perPage = params[:per_page].to_i;
      end
      cookies[:photo_per_page] = { :value => @perPage, :expires => 10.day.from_now }

      @photos = photoRecord.paginate(:page => params[:page], :per_page => @perPage)
    end


    # Use callbacks to share common setup or constraints between actions.
    def set_photo
      @photo = Photo.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def photo_params
      #render :text => params
      params.require(:photo).permit(:title, :image, :content, :geo_latitude, :geo_longitude)
    end

    def save_tags(deleteOldTags = true)
      #delete all old tags
      if (deleteOldTags)
        PhotoTag.delete_all(photo_id: @photo.id)
      end
      #save new tags
      if (params[:tags].length > 0)
        @tags = params[:tags].split(',').uniq
        @tags.each do |tagName|
          tagName = tagName.downcase.strip
          @tag = Tag.find_or_initialize_by(title: tagName, for: Tag::TYPE_PHOTO)
          if (@tag.save)
            @postTag = PhotoTag.find_or_initialize_by(photo_id: @photo.id, tag_id: @tag.id)
            @postTag.save
          end
          #save tags count

        end
      end
    end
end
