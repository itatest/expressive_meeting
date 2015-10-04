class SessionsController < ApplicationController
  
  skip_before_filter :require_login
  
  def new
    if current_user
      if @current_user.org_id
        redirect_to root_url
      else
        redirect_to orgs_path
      end
    end
  end

  def create
    if login(params[:signin][:email], params[:signin][:password], params[:signin][:remember_me])
      params[:signin].delete(:password)
      flash[:notice] = "Signed in successfully."
      redirect_to root_url
    else
      params[:signin].delete(:password)
      flash[:error] = "Authorization failed."
      @login_key = params[:signin][:email]
      render action: :new
    end
  end

  def destroy
    current_user
    logout
    flash[:notice] = "Signed out successfully."
    redirect_to signin_path
  end
  
end
