class PostsController < ApplicationController
  before_action :set_post, only: [:show, :edit, :update, :destroy]

  # GET /posts
  # GET /posts.json
  def index
    getPostsWithFilter
  end

  def filter
    getPostsWithFilter
    render partial: 'table_content', formats: :html
  end


  # GET /posts/1
  # GET /posts/1.json
  def show
  end

  # GET /posts/new
  def new
    @post = Post.new
  end

  # GET /posts/1/edit
  def edit
    @tagsArr = Array.new
    @post.tags.each do |tag|
      @tagsArr.push(tag.title)
    end
  end

  # POST /posts
  # POST /posts.json
  def create
    @post = Post.new(post_params)

    respond_to do |format|
      if @post.save
        save_tags false
        format.html { redirect_to @post, notice: 'Post was successfully created.' }
        format.json { render :show, status: :created, location: @post }
      else
        format.html { render :new }
        format.json { render json: @post.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /posts/1
  # PATCH/PUT /posts/1.json
  def update
    # myParams = post_params
    # render :text => myParams
    respond_to do |format|
      if @post.update(post_params)

        # save tags
        save_tags true

        format.html { redirect_to @post, notice: 'Post was successfully updated.' }
        format.json { render :show, status: :ok, location: @post }
      else
        format.html { render :edit }
        format.json { render json: @post.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /posts/1
  # DELETE /posts/1.json
  def destroy
    @post.destroy
    respond_to do |format|
      format.html { redirect_to posts_url, notice: 'Post was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_post
      @post = Post.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def post_params
      postParams = params.require(:post).permit(:title, :content, :date_from, :date_to, :filter, :geo_latitude, :geo_longitude)
      postParams[:date_from] = postParams[:date_from].to_s.length > 0 ? DateTime.strptime(postParams[:date_from], '%d/%m/%Y') : nil
      postParams[:date_to] = postParams[:date_to].to_s.length > 0 ? DateTime.strptime(postParams[:date_to], '%d/%m/%Y') : nil
      return postParams
    end

    # save tags in create and update post
    def save_tags(deleteOldTags = true)
      #delete all old tags
      if (deleteOldTags)
        PostTag.delete_all(post_id: @post.id)
      end
      #save new tags
      if (params[:tags].length > 0)
        @tags = params[:tags].split(',').uniq
        @tags.each do |tagName|
          tagName = tagName.downcase.strip
          @tag = Tag.find_or_initialize_by(title: tagName);
          if (@tag.save)
            #save linked table
            @postTag = PostTag.find_or_initialize_by(post_id: @post.id, tag_id: @tag.id)
            @postTag.save
          end
          #save tags count

        end
      end
    end


    def getPostsWithFilter

      postRecord = Post

      @sort = {
          :date_from => 'desc'
      }
      if (params[:sort].present?)
        @sort = params[:sort]
      end

      #counts
      postRecord = postRecord.select('posts.*, count(posts_photos.photo_id) as count_photos').joins('LEFT JOIN posts_photos ON posts_photos.post_id = posts.id').group('posts.id')

      if (params[:filter].present?)
        #by name
        postRecord = postRecord.byName(params[:filter][:name])

        # by tags
        if (params[:filter].present? && params[:filter][:tags].present?)
          tags = params[:filter][:tags].split(',').uniq
          postRecord = postRecord.joins(:tags)
          postRecord = postRecord.where('tags.title IN (?)', tags)
        end

        # by dates
        if (params[:filter][:date_from].to_s.length > 0)
          postRecord = postRecord.where('posts.date_from >= ?',  DateTime.strptime(params[:filter][:date_from], '%d/%m/%Y'))
        end
        if (params[:filter][:date_to].to_s.length > 0)
          postRecord = postRecord.where('posts.date_to <= ?',  DateTime.strptime(params[:filter][:date_to], '%d/%m/%Y'))
        end
      end

      @sort.each do |column,direction|
        postRecord = postRecord.order(column.to_s + ' ' + direction.to_s)
      end

      # paging
      @perPage = 1
      if (cookies[:per_page].present?)
        @perPage = cookies[:per_page];
      end
      if (params[:per_page].present? && params[:per_page].to_i > 0)
        @perPage = params[:per_page].to_i;
      end
      cookies[:per_page] = { :value => @perPage, :expires => 10.day.from_now }

      @posts = postRecord.paginate(:page => params[:page], :per_page => @perPage)
    end
end
