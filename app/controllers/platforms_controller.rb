class PlatformsController < ApplicationController
  before_filter :authenticate_user! , :except => :download
  # GET /platforms
  # GET /platforms.json
  def index
    @platforms = Platform.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @platforms }
    end
  end

  # GET /platforms/1
  # GET /platforms/1.json
  def show
    @platform = Platform.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @platform }
    end
  end

  # GET /platforms/new
  # GET /platforms/new.json
  def new
    @platform = Platform.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @platform }
    end
  end

  # GET /platforms/1/edit
  def edit
    @platform = Platform.find(params[:id])
  end

  # POST /platforms
  # POST /platforms.json
  def create
    @platform = Platform.new(params[:platform])

    respond_to do |format|
      if @platform.save
        format.html { redirect_to @platform, notice: 'Platform was successfully created.' }
        format.json { render json: @platform, status: :created, location: @platform }
      else
        format.html { render action: "new" }
        format.json { render json: @platform.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /platforms/1
  # PUT /platforms/1.json
  def update
    @platform = Platform.find(params[:id])

    respond_to do |format|
      if @platform.update_attributes(params[:platform])
        format.html { redirect_to @platform, notice: 'Platform was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @platform.errors, status: :unprocessable_entity }
      end
    end
  end

  def download
    @platform = Platform.find_by_os_name(params[:os_name])
    if(@platform )
      @platform.download_count= @platform.download_count+1
    @platform.save
    @latest_release=@platform.releases.last
    path=@latest_release.dist.path
    send_file(path,:type=>@latest_release.dist.content_type)
    else
      format.html {redirect_to root_url}
    end
  end

  # DELETE /platforms/1
  # DELETE /platforms/1.json
  def destroy
    @platform = Platform.find(params[:id])
    @platform.destroy

    respond_to do |format|
      format.html { redirect_to platforms_url }
      format.json { head :no_content }
    end
  end
end
