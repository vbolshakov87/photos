class PostsController < ApplicationController
  before_action :set_post, only: [:show, :edit, :update, :destroy]

  # GET /posts
  # GET /posts.json
  def index
    @posts = Post.all
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
    save_tags false

    respond_to do |format|
      if @post.save
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
      postParams = params.require(:post).permit(:title, :content, :date_from, :date_to)
      postParams[:date_from] = DateTime.strptime(postParams[:date_from], '%d/%m/%Y')
      postParams[:date_to] = DateTime.strptime(postParams[:date_to], '%d/%m/%Y')
      return postParams
    end

    # save tags in create and update post
    def save_tags(deleteOldTags = true)
      #delete all old tags
      if (deleteOldTags)
        PostTag.delete_all(post_id: @post.id)
      end
      #save new tags
      if (params[:tags].length)
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
end
