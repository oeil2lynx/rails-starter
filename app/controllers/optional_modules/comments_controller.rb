#
# == CommentsController
#
class CommentsController < ApplicationController
  before_action :comment_module_enabled?
  before_action :load_commentable
  before_action :set_comment, only: [:signal, :destroy]
  before_action :set_comment_setting

  decorates_assigned :comment, :about, :blog

  # POST /comments
  # POST /comments.json
  def create
    if comment_params[:nickname].blank?
      @comment = @commentable.comments.new(comment_params)
      @comment.user_id = current_user.id if user_signed_in?
      @comment.validated = @setting.should_validate? ? false : true
      if @comment.save
        flash.now[:success] = I18n.t('comment.create_success')
        flash.now[:success] = I18n.t('comment.create_success_with_validate') if @setting.should_validate?
        respond_action 'create'
      else # Render view user come from instead of the comments default view
        instance_variable_set("@#{@commentable.class.name.underscore}", @commentable)
        @comments = CommentDecorator.decorate_collection(paginate_commentable)
        render "#{@commentable.class.name.underscore.pluralize}/show"
      end
    else # if nickname is filled => robots spam
      flash.now[:error] = I18n.t('comment.captcha')
      respond_action 'captcha'
    end
  end

  # DELETE /comments/1
  # DELETE /comments/1.json
  def destroy
    if can? :destroy, @comment
      @comment_children = @comment.child_ids if @comment.has_children?
      if @comment.destroy
        flash.now[:error] = nil
        flash.now[:success] = I18n.t('comment.destroy.success')
        respond_action 'destroy'
      else
        flash.now[:success] = nil
        flash.now[:error] = I18n.t('comment.destroy.error')
        respond_action 'forbidden'
      end
    else
      flash.now[:success] = nil
      flash.now[:error] = I18n.t('comment.destroy.not_allowed')
      respond_action 'forbidden'
    end
  end

  def signal
    fail ActionController::RoutingError, 'Not Found' unless @comment_setting.should_signal?
    @comment.update_attribute(:signalled, true)

    CommentJob.set(wait: 3.seconds).perform_later(@comment) if @comment_setting.send_email?
    flash.now[:success] = I18n.t('comment.signalled.success')

    respond_to do |format|
      format.html { redirect_to :back }
      format.js { }
    end
  end

  def reply
    @comment = @commentable.comments.new(parent_id: params[:id])
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_comment
    @comment = @commentable.comments.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    raise ActionController::RoutingError, 'Not Found'
  end

  def set_comment_setting
    @comment_setting = CommentSetting.first
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def comment_params
    params.require(:comment).permit(:username, :email, :title, :comment, :lang, :user_id, :nickname, :parent_id)
  end

  def load_commentable
    klass = [About, Blog].detect { |c| params["#{c.name.underscore}_id"] }
    @commentable = klass.find(params["#{klass.name.underscore}_id"])
    @category = Category.find_by(name: klass.model_name.to_s)
    @controller_name = klass.name.underscore.pluralize
    redirect_to root_path unless @commentable.allow_comments?
  end

  def paginate_commentable
    @commentable.comments.validated.by_locale(@language).includes(:user).page params[:page]
  end

  def respond_action(template)
    respond_to do |format|
      format.html { redirect_to @commentable }
      format.js { render template }
    end
  end

  def comment_module_enabled?
    not_found unless @comment_module.enabled?
  end
end
