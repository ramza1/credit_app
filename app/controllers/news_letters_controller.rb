class NewsLettersController < ApplicationController
  before_filter :authenticate_user!
  before_filter :check_if_admin
  def index
    @news_letters = NewsLetter.order("created_at desc")
  end

  def new
    @news_letter = NewsLetter.new
  end

  def edit
    @news_letter = NewsLetter.find(params[:id])
  end

  def show
    @news_letter = NewsLetter.find(params[:id])
  end

  def create
    @news_letter = NewsLetter.new(params[:news_letter])
    if @news_letter.save
      redirect_to news_letter_url(@news_letter), notice: 'News letter was successfully created.'
    else
      render action: "new"
    end
  end

  def send_now
    @news_letter = NewsLetter.find(params[:id])
    if User.any?
      User.find_each do |mailing_list|
        SubscriberLetterWorker.perform_async(mailing_list.id, @news_letter.id)
        #SubscriberMailer.send_news_letter(mailing_list, @news_letter).deliver
      end
      redirect_to news_letter_path(@news_letter), notice: "Sent news Letter"
    else
      redirect_to news_letter_path(@news_letter), alert: "Sorry no subscribers at the moment"
    end
  end

  def update
    @news_letter = NewsLetter.find(params[:id])
    if @news_letter.update_attributes(params[:news_letter])
      respond_to do |format|
        format.html {redirect_to news_letter_path(@news_letter), notice: "Updated News letter"}
      end
    else
      render action: 'edit'
    end
  end

  def destroy
    @news_letter = NewsLetter.find(params[:id])
    @news_letter.destroy
    redirect_to news_letters_path, notice: "Deleted News letter"
  end

  def check_if_admin
    unless current_user.admin?
      redirect_to root_url
    end
  end

end
