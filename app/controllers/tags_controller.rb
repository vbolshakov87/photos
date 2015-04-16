class TagsController < ApplicationController
  before_action :set_tag, only: [:show, :edit, :update, :destroy]

  # GET /tags
  # GET /tags.json
  def index
    get_tags_with_filter
  end

  def filter
    get_tags_with_filter
    render partial: 'table_content', formats: :html
  end


  # GET /tags/1
  # GET /tags/1.json
  def show
  end

  # GET /tags/new
  def new
    @tag = Tag.new
  end

  def autocomplete
    term = params[:term]
    essence = params[:essence]
    max_count = !params[:max_count].blank? && params[:max_count].to_i > 1 ? params[:max_count].to_i : 10

    tags_criteria = Tag.limit(max_count)
    tags_criteria = essence == Tag::TYPE_POST ? tags_criteria.from_post : tags_criteria.from_photo

    if (term.empty?)
      @tags = tags_criteria.all
    else
      @tags = tags_criteria.search_by_tag(term).all
    end

    tags_titles = Array.new
    @tags.each do |tag|
      tags_titles.push(tag.title)
    end
    render :json => tags_titles
  end




  # GET /tags/1/edit
  def edit
  end

  # POST /tags
  # POST /tags.json
  def create
    @tag = Tag.new(tag_params)

    respond_to do |format|
      if @tag.save
        format.html { redirect_to @tag, notice: 'Tag was successfully created.' }
        format.json { render :show, status: :created, location: @tag }
      else
        format.html { render :new }
        format.json { render json: @tag.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /tags/1
  # PATCH/PUT /tags/1.json
  def update
    respond_to do |format|
      if @tag.update(tag_params)
        format.html { redirect_to @tag, notice: 'Tag was successfully updated.' }
        format.json { render :show, status: :ok, location: @tag }
      else
        format.html { render :edit }
        format.json { render json: @tag.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /tags/1
  # DELETE /tags/1.json
  def destroy
    @tag.destroy
    respond_to do |format|
      format.html { redirect_to tags_url, notice: 'Tag was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_tag
      @tag = Tag.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def tag_params
      params.require(:tag).permit(:title, :count)
    end

  def get_tags_with_filter

    tags_record = Tag

    @sort = {
        :title => 'asc'
    }
    if (params[:sort].present?)
      @sort = params[:sort]
    end

    if (params[:filter].present?)
      #by name
      tags_record = tags_record.search_by_tag(params[:filter][:name])

      # by post
      if (params[:filter][:posts].present?)
        posts = params[:filter][:posts].split(',').uniq
        tags_record = tags_record.joins(:posts)
        tags_record = tags_record.where('posts.id IN (?)', posts)
      end

      # by photo
      if (params[:filter][:photos].present?)
        posts = params[:filter][:photos].split(',').uniq
        tags_record = tags_record.joins(:photos)
        tags_record = tags_record.where('photos.id IN (?)', photos)
      end

    end

    @sort.each do |column,direction|
      tags_record = tags_record.order(column.to_s + ' ' + direction.to_s)
    end

    # paging
    @per_page = 1
    if (cookies[:tags_per_page].present?)
      @per_page = cookies[:tags_per_page];
    end
    if (params[:per_page].present? && params[:per_page].to_i > 0)
      @per_page = params[:per_page].to_i;
    end
    cookies[:tags_per_page] = { :value => @per_page, :expires => 10.day.from_now }

    @tags = tags_record.paginate(:page => params[:page], :per_page => @per_page)
  end
  
end
