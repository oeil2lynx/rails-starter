# frozen_string_literal: true

#
# == CommentsController
#
class CommentsController < ApplicationController
  include OptionalModules::CommentHelper
  include ModuleSettingable

  before_action :comment_module_enabled?
  before_action :set_page, only: [:reply]
  before_action :set_background, only: [:reply]
  before_action :load_commentable
  before_action :set_comment, only: [:reply, :signal, :destroy]
  before_action :set_comments, only: [:create]
  before_action :redirect_to_back_after_destroy?, only: [:destroy]
  before_action :set_current_user, only: [:create]
  before_action :set_commentable_show_page, only: [:destroy], if: proc { @redirect_to_back }

  # WebSockets
  after_action :broadcast_comment,
               only: :create,
               if: proc { @comment.persisted? }

  # Mailer
  after_action :comment_created, only: [:create], if: :email_comment_created?
  after_action :comment_signalled, only: [:signal], if: :email_comment_signalled?

  include DeletableCommentable

  decorates_assigned :comment, :about, :blog, :page

  # POST /comments
  # POST /comments.json
  def create
    @comment = @commentable.comments.new(comment_params)
    @comment.user_id = current_user.id if user_signed_in?
    if @comment.save
      flash.now[:success] = I18n.t('comment.create_success')
      flash.now[:success] = I18n.t('comment.create_success_with_validate') if @comment_setting.should_validate? && !current_user_and_administrator?(User.current_user)
      respond_action 'create'
    else
      flash.now[:error] = I18n.t('comment.create_error')
      respond_action 'forbidden'
    end
  end

  def signal
    raise ActionController::RoutingError, 'Not Found' if !@comment_setting.should_signal? || !params[:token] || @comment.try(:token) != params[:token]
    @comment.update_attribute(:signalled, true)

    flash.now[:success] = I18n.t('comment.signalled.success')

    respond_to do |format|
      format.html { redirect_back(fallback_location: root_path) }
      format.js {}
    end
  end

  def reply
    raise ActionController::RoutingError, 'Not Found' if !params[:token] || @comment.try(:token) != params[:token] || cannot?(:reply, @comment)
    return if @comment.max_depth?

    @parent_comment = @comment
    @comment = @commentable.comments.new(parent_id: params[:id])
    @asocial = true
    seo_tag_custom I18n.t('comment.seo.title', article: @commentable.title), I18n.t('comment.seo.description')

    respond_to do |format|
      format.html {}
      format.js {}
    end
  end

  private

  def comment_params
    a = [:username, :email, :title, :comment, :lang, :user_id, :nickname]
    a.push(:parent_id) if @comment_setting.allow_reply?
    params.require(:comment).permit(a)
  end

  def set_comment
    @comment = @commentable.comments.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    raise ActionController::RoutingError, 'Not Found'
  end

  def load_commentable
    klass = [About, Blog].detect { |c| params["#{c.name.underscore}_id"] }
    @commentable = klass.friendly.find(params["#{klass.name.underscore}_id"])
    @page = @pages.find_by(name: klass.model_name.to_s)
    @controller_name = klass.name.underscore.pluralize
    redirect_to root_path unless @commentable.allow_comments?
  end

  def set_comments
    paginated_comments = @commentable.comments.validated.by_locale(@language).includes(:user).page params[:page]
    @comments = CommentDecorator.decorate_collection(paginated_comments)
  end

  def respond_action(template)
    respond_to do |format|
      format.html { redirect_to @commentable.decorate.show_post_link }
      format.js { render template }
    end
  end

  def comment_module_enabled?
    not_found unless @comment_module.enabled?
  end

  def set_commentable_show_page
    @show_page = send("#{@commentable.class.name.underscore.singularize}_path", @commentable)
  end

  def redirect_to_back_after_destroy?
    @redirect_to_back = !@comment.nil? && params[:current_comment_action] == 'reply' && (
      @comment.root? ||
      @comment.id == params[:current_comment_id].to_i ||
      @comment.children_ids.include?(params[:current_comment_id].to_i)
    )
  end

  def set_current_user
    User.current_user = try(:current_user)
  end

  def set_page
    @page = Page.find_by(name: 'Blog')
  end

  #
  # WebSockets
  # ============
  def broadcast_comment
    ActionCable.server.broadcast('comment', comment: comment)
  end

  #
  # == Callback action
  #
  def email_comment_created?
    @comment_setting.send_email? &&
      !current_user_and_administrator? &&
      @comment.persisted?
  end

  def email_comment_signalled?
    @comment.signalled? &&
      @comment_setting.send_email?
  end

  #
  # == Mailer Job
  #
  def comment_created
    CommentCreatedJob.set(wait: 3.seconds).perform_later(@comment)
  end

  def comment_signalled
    CommentSignalledJob.set(wait: 3.seconds).perform_later(@comment)
  end
end
