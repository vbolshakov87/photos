class PhotosController < ApplicationController
  before_action :set_photo, only: [:show, :edit, :update, :destroy]

  # GET /photos
  def index
    get_photos_with_filter
  end

  def filter
    get_photos_with_filter
    @show_filter = true
    render partial: 'photo_list', formats: :html
  end

  def autocomplete
    term = params[:term]
    max_count = !params[:max_count].blank? && params[:max_count].to_i > 1 ? params[:max_count].to_i : 10

    photo_criteria = Photo.limit(max_count)

    if (term.empty?)
      photos = photo_criteria.all
    else
      photos = photo_criteria.by_name(term).all
    end

    photo_title_arr = Array.new
    photos.each do |photo|
      photo_title_arr.push(
          {
              :label => photo.title,
              :value => ApplicationHelper::Photo.post_autocomplete_title(post),
              :id => post.id
          }
      )
    end
    render :json => photo_title_arr
  end


  # GET /photos/1
  # GET /photos/1.json
  def show
  end

  def forpost
    post_id = params[:post]
    if (!post_id)
      raise 'there is no post in in input params'
    end

    @photos = Photo.sort_photos_asc.from_post(post_id).all
    @post = Post.find(post_id)

    respond_to do |format|
      format.html
      format.json { render json: @photos.map{|photo| photo.to_jq_upload } }
    end
  end

  def post_gallery_ajax
    post_id = params[:post]
    if (!post_id)
      raise 'there is no post in in input params'
    end

    @photos = Photo.sort_photos_asc.from_post(post_id).all
    render partial: 'post_gallery_ajax', formats: :html
  end


  def popup
    photo_id = params[:photo]
    if (!photo_id)
      raise 'there is no post in in input params'
    end

    @photo = Photo.find(photo_id)
    @posts = Post.joins(:posts_photos).where('posts_photos.photo_id = ?', photo_id)

    @tags_arr = Array.new
    @post_arr = Array.new

    if (!@posts.empty?)
      tags = @photo.tags.any? ?  @photo.tags : @posts[0].tags
      tags.each do |tag|
        @tags_arr.push(tag.title)
      end

      @posts.each do |post|
        @post_arr.push(ApplicationHelper::Post.post_autocomplete_title(post))
      end
    end

    #default values
    @photo.geo_latitude = @photo.geo_latitude.present? ? @photo.geo_latitude : (@posts[0].present? ? @posts[0].geo_latitude : Rails.application.config.default_geo_latitude )
    @photo.geo_longitude = @photo.geo_longitude.present? ? @photo.geo_longitude : (@posts[0].present? ? @posts[0].geo_longitude : Rails.application.config.default_geo_longitude )
    @exif = ActiveSupport::JSON.decode(@photo.exif)
    render partial: 'popup', formats: :html
  end

  def exif
    photo_id = params[:photo]
    if (!photo_id)
      raise 'there is no post in in input params'
    end

    photo = Photo.find(photo_id)
    path = Rails.root + photo.image.path(:original)

    @exif_raw_hash = {}
    exifRaw = %x(identify -verbose #{path}).split("\n")
    exifRaw.each do |exifString|
      exif_arr = exifString.sub('exif:', '').strip.split(':').collect { |x| x.strip }
      #if (['Image', 'Format', 'Mime', 'Geometry', 'Resolution', 'Colorspace', 'Depth', 'Pixels', 'Quality', 'Orientation', 'DateTime', 'FocalLength', 'FocalLengthIn35mmFilm', 'Make', 'MaxApertureValue', 'Model', 'Software', 'Created Date[2,55]', 'Version'].include?(exif_arr[0]))
        @exif_raw_hash[exif_arr[0]] = exif_arr[1]
      #end
      #render :text => exif_arr
      #break
    end
  end

  # sort images
  def sort
    post_id = params[:post]
    sorted = params[:sorted].uniq

    # get ids from the DB
    existValues = Photo.where('`photos`.`id` IN (?)', sorted).from_post(post_id).select('photos.id').all.to_a
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
        raise "error photo id=#{value} does not exist in a post #{post_id}"
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

          post_photo = PostPhoto.find_or_initialize_by(post_id: params[:post_id], photo_id: @photo.id)
          post_photo.save

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
          posts.each do |post_id|
            post_photo = PostPhoto.find_or_initialize_by(post_id: post_id, photo_id: @photo.id)
            post_photo.save
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
      first_photo = Photo.sort_photos_asc.from_post(post.id).first
      if (first_photo.present?)
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

    def get_photos_with_filter
      photo_record = Photo

      @sort = {
          :created_at => 'desc'
      }
      if (params[:sort].present?)
        @sort = params[:sort]
      end

      #counts
      photo_record = photo_record.select('photos.*').joins('LEFT JOIN posts_photos ON posts_photos.photo_id = photos.id').joins('LEFT JOIN posts ON posts_photos.post_id = posts.id')

      if (params[:filter].present?)
        #by name
        photo_record = photo_record.by_name(params[:filter][:name])

        # by tags
        if (params[:filter].present? && params[:filter][:tags].present?)
          tags = params[:filter][:tags].split(',').uniq
          photo_record = photo_record.joins(:tags)
          photo_record = photo_record.where('tags.title IN (?)', tags)
        end

        # by dates
        if (params[:filter][:date_from].to_s.length > 0)
          photo_record = photo_record.where('posts.date_from >= ?',  DateTime.strptime(params[:filter][:date_from], '%d/%m/%Y'))
        end
        if (params[:filter][:date_to].to_s.length > 0)
          photo_record = photo_record.where('posts.date_to <= ?',  DateTime.strptime(params[:filter][:date_to], '%d/%m/%Y'))
        end
      end

      @sort.each do |column,direction|
        photo_record = photo_record.order(column.to_s + ' ' + direction.to_s)
      end

      # paging
      @per_page = 4
      if (cookies[:photo_per_page].present?)
        @per_page = cookies[:photo_per_page];
      end
      if (params[:per_page].present? && params[:per_page].to_i > 0)
        @per_page = params[:per_page].to_i;
      end
      cookies[:photo_per_page] = { :value => @per_page, :expires => 10.day.from_now }

      @photos = photo_record.paginate(:page => params[:page], :per_page => @per_page)
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

    def save_tags(delete_old_tags = true)
      #delete all old tags
      if (delete_old_tags)
        PhotoTag.delete_all(photo_id: @photo.id)
      end
      #save new tags
      if (params[:tags].length > 0)
        tags = params[:tags].split(',').uniq
        tags.each do |tag_name|
          tag_name = tag_name.downcase.strip
          tag = Tag.find_or_initialize_by(title: tag_name, for: Tag::TYPE_PHOTO)
          if (tag.save)
            postTag = PhotoTag.find_or_initialize_by(photo_id: @photo.id, tag_id: tag.id)
            postTag.save
          end
          #save tags count

        end
      end
    end
end
