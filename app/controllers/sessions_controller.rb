class SessionsController < ApplicationController

  # GET /login
  def index
    @title = "Welcome"
  end

  # GET /auth/:provider/callback
  def create
    new_path = "/"

    if 'meetup' == params[:provider]
      user = create_meetup
      if user.should_sync
        new_path = "/account"
      end
    elsif 'github' == params[:provider]
      user = create_github
    else
      flash[:alert] = "Cannot accept authorization from #{params[:provider]}"
      redirect_to "/login"
      return
    end

    redirect_to new_path

    rescue Exception => e
      flash[:alert] = e.message
      logger.info e.message
      logger.info e.backtrace.join("\n")
      redirect_to "/login"
  end

  # GET /signout
  def signout
    clear_session
    redirect_to "/"
  end


  protected
    def omniauth_hash
      request.env['omniauth.auth']
    end

    def create_meetup
      user = User.find_or_create_from_meetup(omniauth_hash)
      session[:mu_uid] = user.uid
      session[:mu_name] = user.mu_name
      session[:provider] = user.provider
      user
    end

    def create_github
      puts omniauth_hash
      current_user
    end

end
