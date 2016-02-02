#
# == GuestBooks Controller
#
class GuestBooksController < ApplicationController
  before_action :guest_book_module_enabled?
  before_action :set_guest_books
  before_action :set_guest_book, only: :destroy

  # GET /livre-d-or
  # GET /livre-d-or.json
  def index
    seo_tag_index category
  end

  # POST /livre-d-or
  # POST /livre-d-or.json
  def create
    if guest_book_params[:nickname].blank?
      @guest_book = GuestBook.new(guest_book_params)
      if @guest_book.save
        @guest_book = CommentDecorator.decorate(@guest_book)
        flash.now[:success] = I18n.t('guest_book.success')
        respond_action 'create', false
      else
        respond_action :index, true
      end
    else # if nickname is filled => robots spam
      flash.now[:error] = 'Captcha caught you'
      respond_action 'captcha', false
    end
  end

  # DELETE /livre-d-or/1
  # DELETE /livre-d-or/1.json
  def destroy
    if can? :destroy, @guest_book
      if @guest_book.destroy
        flash.now[:error] = nil
        flash.now[:success] = I18n.t('comment.destroy.success')
        respond_action 'destroy'
      else
        flash.now[:success] = nil
        flash.now[:error] = I18n.t('comment.destroy.error')
        respond_action 'comments/forbidden'
      end
    else
      flash.now[:success] = nil
      flash.now[:error] = I18n.t('comment.destroy.not_allowed')
      respond_action 'comments/forbidden'
    end
  end

  private

  def set_guest_book
    @guest_book = GuestBook.find(params[:id])
  end

  def set_guest_books
    @guest_book = GuestBook.new
    guest_books = GuestBook.validated.by_locale(@language)
    @guest_books = CommentDecorator.decorate_collection(guest_books.page params[:page])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def guest_book_params
    params.require(:guest_book).permit(:username, :email, :lang, :content, :nickname)
  end

  def respond_action(template, should_render = false)
    respond_to do |format|
      format.html { redirect_to guest_books_path, flash: { success: I18n.t('guest_book.success') } } unless should_render
      format.html { render template } if should_render
      format.js { render template }
    end
  end

  def guest_book_module_enabled?
    not_found unless @guest_book_module.enabled?
  end
end
