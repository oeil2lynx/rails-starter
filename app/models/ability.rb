#
# == Ability Class
#
class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new # visitor user (not logged in)

    alias_action :create, :read, :update, :destroy, to: :crud

    if user.super_administrator?
      super_administrator_privilege(user)
    elsif user.administrator?
      administrator_privilege(user)
    elsif user.subscriber?
      subscriber_privilege(user)
    else
      visitor_privilege
    end
  end

  private

  def super_administrator_privilege(user)
    can :manage, :all
    cannot [:update, :destroy], User, role: { name: 'super_administrator' }
    can :manage, User, id: user.id
    optional_modules_check(user)
  end

  def administrator_privilege(user)
    can :read, :all
    can :manage, Post
    can :update, [Setting, Category]
    can [:read, :update], Menu
    can [:read, :destroy, :update], User, role_name: %w( subscriber )
    cannot :create, User
    cannot [:update, :destroy], User, role: { name: %w( administrator ) }
    cannot :manage, User, role: { name: %w( super_administrator ) }
    can :manage, User, id: user.id
    can [:read, :update, :destroy], Picture
    cannot :manage, OptionalModule
    cannot [:read, :update, :destroy], About
    can :manage, About, user_id: user.id
    can [:read, :update], StringBox
    optional_modules_check(user)
  end

  def subscriber_privilege(user)
    cannot_manage_optional_modules
    can [:update, :read, :destroy], User, id: user.id
    cannot :create, User
    can [:create, :read, :destroy], Comment, user_id: user.id
    cannot :destroy, Comment, user_id: nil
    cannot :manage, [Home, About, Setting, Picture, StringBox, Menu]
    can :read, ActiveAdmin::Page, name: 'Dashboard'
  end

  def visitor_privilege
    can :read, Post
    cannot [:create, :update, :destroy], :all
    cannot_manage_optional_modules
  end

  def cannot_manage_optional_modules
    cannot :manage, [OptionalModule, GuestBook, NewsletterUser, Comment, Blog, Slider, Event, Map, Newsletter, Social, Background]
  end

  def optional_modules_check(user)
    optional_modules = OptionalModule.all
    optional_modules.find_each do |optional_module|
      instance_variable_set("@#{optional_module.name.underscore.singularize}_module", optional_module)
    end

    #
    # == GuestBook
    #
    if @guest_book_module.enabled?
      can [:read, :destroy], GuestBook
      cannot [:create, :update], GuestBook
    else
      cannot :manage, GuestBook
    end

    #
    # == Newsletter
    #
    if @newsletter_module.enabled?
      can :manage, Newsletter
      can [:create, :read, :update, :destroy], NewsletterUser
    else
      cannot :manage, Newsletter
      cannot :manage, NewsletterUser
    end

    #
    # == Comment
    #
    if @comment_module.enabled?
      can [:read, :destroy], Comment, user: { role_name: %w( administrator subscriber ) }
      can [:read, :destroy], Comment, user_id: nil
      cannot [:create, :update], Comment
      can :destroy, Comment if user.super_administrator?
    else
      cannot :manage, Comment
    end

    #
    # == Blog
    #
    if @blog_module.enabled?
      can :crud, Blog
    else
      cannot :manage, Blog
    end

    #
    # == Slider
    #
    if @slider_module.enabled?
      can :crud, [Slider, Slide]
      cannot :create, Slide
    else
      cannot :manage, [Slider, Slide]
    end

    #
    # == Event
    #
    if @event_module.enabled?
      can :crud, Event
    else
      cannot :manage, Event
    end

    #
    # == Map
    #
    if @map_module.enabled?
      can [:update, :read], Map
      cannot [:create, :destroy], Map
    else
      cannot :manage, Map
    end

    #
    # == Map
    #
    if @social_module.enabled?
      can [:update, :read], Social
      cannot [:create, :destroy], Social if user.administrator?
    else
      cannot :manage, Social
    end

    #
    # == Background
    #
    if @background_module.enabled?
      can :crud, Background
    else
      cannot :manage, Background
    end
  end
end
