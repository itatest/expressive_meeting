class UsersController < ApplicationController
  
  def index
    authorize! :create, User
    @users = @current_user.fetch_users
  end

  def new
    authorize! :create, User
    @user = User.new
    set_candidate_roles
  end
  
  def show
    if @user.id == @current_user.id
      authorize! :update, @user
    else
      authorize! :create, @user
      raise CanCan::AccessDenied unless @current_user.higher_or_same_privilege?(@user)
    end
    set_candidate_roles
  end

  def create
    authorize! :create, User
    
    @user = User.new(user_params)
    begin
      if Role.has_master?(role_params)
        unless @current_user.master?
          raise I18n.t('controller.users.invalid_role')
        end
        @user.roles << Role.fetch_master_role
      else
        if !@current_user.master? && !@current_user.admin?
          if Role.has_admin?(role_params)
            raise I18n.t('controller.users.invalid_role')
          end
        end
        @user.org_id = @current_user.org_id
        @user.relate_roles(role_params)
      end
    rescue => e
      set_candidate_roles
      flash[:alert] = e.message
      render "new"
      clear_flash
      return
    end
    if @user.save
      flash[:notice] = I18n.t('controller.users.created')
      redirect_to users_path
      return
    else
      set_candidate_roles
      flash[:alert] = I18n.t('controller.users.not_created')
      render "new"
      clear_flash
      return
    end
  end
  
  def update
    # self user update
    if @user.id == @current_user.id
      authorize! :update, @user
      case params[:operation]
      when "update_profile"
        if @user.update(basic_params)
          flash[:notice] = I18n.t('controller.users.updated')
        else
          flash[:alert] = I18n.t('controller.users.not_updated')
        end
      when "update_password"
        if user_class.authenticate(@user.email, password_params[:current_password]).blank?
          flash[:alert] = I18n.t('controller.users.not_updated')
          @user.errors.messages[:current_password] = [I18n.t('controller.users.auth_failed')]
        else
          if @user.update(password_params)
            flash[:notice] = I18n.t('controller.users.updated')
          else
            flash[:alert] = I18n.t('controller.users.not_updated')
          end
        end
      when "update_token"
        if @user.republish_token
          flash[:notice] = I18n.t('controller.users.updated')
        else
          flash[:alert] = I18n.t('controller.users.not_updated')
        end
      end
    # other user update
    else
      authorize! :create, @user
      raise CanCan::AccessDenied unless @current_user.higher_or_same_privilege?(@user)
      case params[:operation]
      when "update_profile"
        if @user.update(basic_params)
          flash[:notice] = I18n.t('controller.users.updated')
        else
          flash[:alert] = I18n.t('controller.users.not_updated')
        end
      when "update_password"
        if @user.update(password_params)
          flash[:notice] = I18n.t('controller.users.updated')
        else
          flash[:alert] = I18n.t('controller.users.not_updated')
        end
      when "update_token"
        if @user.republish_token
          flash[:notice] = I18n.t('controller.users.updated')
        else
          flash[:alert] = I18n.t('controller.users.not_updated')
        end
      when "update_role"
        begin
          if Role.has_master?(role_params)
            unless @current_user.master?
              raise I18n.t('controller.users.invalid_role')
            end
            @user.org_id = nil
            @user.roles.clear
            @user.roles << Role.fetch_master_role
          else
            if !@current_user.master? && !@current_user.admin?
              if Role.has_admin?(role_params)
                raise I18n.t('controller.users.invalid_role')
              end
            end
            @user.org_id = @current_user.org_id
            @user.relate_roles(role_params)
          end
          if @user.save
            flash[:notice] = I18n.t('controller.users.updated')
          else
            flash[:alert] = I18n.t('controller.users.not_updated')
          end
        rescue => e
          flash[:alert] = e.message
        end
      end
    end
    set_candidate_roles
    render "show"
    clear_flash
    return
  end
  
  def destroy
    authorize! :destroy, @user
    if @current_user == @user || !@current_user.higher_or_same_privilege?(@user)
      flash[:alert] = I18n.t('controller.users.not_destroyed')
    else
      if @user.destroy
        flash[:notice] = I18n.t('controller.users.destroyed')
      else
        flash[:alert] = I18n.t('controller.users.not_destroyed')
      end
    end
    redirect_to users_path
  end
  
  private
 
  def user_params
    if Settings.login_key == "user_id"
      params.require(:user).permit(:user_id, :name, :email, :password, :password_confirmation)
    else
      params.require(:user).permit(:name, :email, :password, :password_confirmation)
    end
  end
  
  def basic_params
    if Settings.login_key == "user_id"
      params.require(:user).permit(:user_id, :name, :email)
    else
      params.require(:user).permit(:name, :email)
    end
  end
  
  def password_params
    params.require(:user).permit(:password, :password_confirmation, :current_password)
  end
  
  def role_params
    params.require(:roles)
  rescue
    raise I18n.t('controller.users.required_role')
  end
  
  def set_user
    @user = User.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    flash[:alert] = I18n.t('controller.users.not_found')
    redirect_to users_path
  end
  
  def deny_user
    unless @current_user.master?
      raise CanCan::AccessDenied if @user.org_id != @current_user.org_id
    end
  end
  
  def set_candidate_roles
    @candidate_roles = @current_user.fetch_roles.reject{|role| @user.roles.include?(role)}
    if !@current_user.master? && !@current_user.admin?
      @candidate_roles.reject!{|role| role.admin}
    end
  end
end