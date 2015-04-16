class PostsController < ApplicationController
  before_action :set_post, only: [:show, :edit, :update, :destroy]

  # GET /posts
  # GET /posts.json
  def index
    get_posts_with_filter
  end

  def filter
    get_posts_with_filter
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
    @tags_arr = Array.new
    @post.tags.each do |tag|
      @tags_arr.push(tag.title)
    end

    @category_active_ids = Array.new
    @post.categories_posts.each do |cat_post|
      @category_active_ids.push(cat_post.category_id)
    end

  end

  # POST /posts
  # POST /posts.json
  def create
    @post = Post.new(post_params)

    respond_to do |format|
      if @post.save

        save_tags false
        save_categories false

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
        save_categories true

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


  def autocomplete
    term = params[:term]
    max_count = !params[:max_count].blank? && params[:max_count].to_i > 1 ? params[:max_count].to_i : 10

    post_criteria = Post.limit(max_count)

    if (term.empty?)
      posts = post_criteria.all
    else
      posts = post_criteria.by_name(term).all
    end

    post_title_arr = Array.new
    posts.each do |post|
      post_title_arr.push(
          {
              :label => post.title,
              :value => ApplicationHelper::Post.post_autocomplete_title(post),
              :id => post.id
          }
      )
    end
    render :json => post_title_arr
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
    def save_tags(delete_old_tags = true)
      #delete all old tags
      if (delete_old_tags)
        PostTag.delete_all(post_id: @post.id)
      end
      #save new tags
      if (params[:tags].length > 0)
        tags = params[:tags].split(',').uniq
        tags.each do |tag_name|
          tag_name = tag_name.downcase.strip
          tag = Tag.find_or_initialize_by(title: tag_name, for: Tag::TYPE_POST)
          if (tag.save)
            #save linked table
            postTag = PostTag.create(post_id: @post.id, tag_id: tag.id)
            postTag.save
          end
        end
      end
    end


    def save_categories(delete_old_categories = true)
      #delete all old tags
      if (delete_old_categories)
        CategoryPost.delete_all(post_id: @post.id)
      end
      #save new categories
      if (params[:category].present? && params[:category].length > 0)
        params[:category].keys.each do |cat_id|
          category = Category.find(cat_id)
          if (!category)
            raise "Category #{cat_id} is not found"
          end
          #save linked table
          category.path_ids.each do |path_cat_id|
            categoryPost = CategoryPost.find_or_initialize_by(post_id: @post.id, category_id: path_cat_id)
            if (!categoryPost.save)
              raise "CategoryPost is not saved"
            end
          end
        end
      end
    end


    def get_posts_with_filter

      post_record = Post

      @sort = {
          :date_from => 'desc'
      }
      if (params[:sort].present?)
        @sort = params[:sort]
      end

      #counts
      post_record = post_record.select('posts.*, count(posts_photos.photo_id) as count_photos').joins('LEFT JOIN posts_photos ON posts_photos.post_id = posts.id').group('posts.id')

      if (params[:filter].present?)
        #by name
        post_record = post_record.by_name(params[:filter][:name])

        # by tags
        if (params[:filter][:tags].present?)
          tags = params[:filter][:tags].split(',').uniq
          post_record = post_record.joins(:tags)
          post_record = post_record.where('tags.title IN (?)', tags)
        end

        # by category
        if (params[:filter][:category].present?)
          post_record = post_record.joins(:categories_posts)
          post_record = post_record.where('categories_posts.category_id = ?', params[:filter][:category])
        end

        # by dates
        if (params[:filter][:date_from].to_s.length > 0)
          post_record = post_record.where('posts.date_from >= ?',  DateTime.strptime(params[:filter][:date_from], '%d/%m/%Y'))
        end
        if (params[:filter][:date_to].to_s.length > 0)
          post_record = post_record.where('posts.date_to <= ?',  DateTime.strptime(params[:filter][:date_to], '%d/%m/%Y'))
        end
      end

      @sort.each do |column,direction|
        post_record = post_record.order(column.to_s + ' ' + direction.to_s)
      end

      # paging
      @per_page = 1
      if (cookies[:per_page].present?)
        @per_page = cookies[:per_page];
      end
      if (params[:per_page].present? && params[:per_page].to_i > 0)
        @per_page = params[:per_page].to_i;
      end
      cookies[:per_page] = { :value => @per_page, :expires => 10.day.from_now }

      @posts = post_record.paginate(:page => params[:page], :per_page => @per_page)
    end
end
