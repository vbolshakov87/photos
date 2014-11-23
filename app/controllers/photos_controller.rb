class PhotosController < ApplicationController
  before_action :set_photo, only: [:show, :edit, :update, :destroy]

  # GET /photos
  # GET /photos.json
  def index
    @photos = Photo.sortPhotosAsc.all
    respond_to do |format|
      format.html
      format.json { render json: @photos.map{|photo| photo.to_jq_upload } }
    end

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
    respond_to do |format|
      if @photo.update(photo_params)
        format.html { redirect_to @photo, notice: 'Photo was successfully updated.' }
        format.json { render :show, status: :ok, location: @photo }
      else
        format.html { render :edit }
        format.json { render json: @photo.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /photos/1
  # DELETE /photos/1.json
  def destroy
    @photo.destroy
    respond_to do |format|
      format.html { redirect_to photos_url, notice: 'Photo was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_photo
      @photo = Photo.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def photo_params
      #render :text => params
      params.require(:photo).permit(:title, :image)
    end
end
