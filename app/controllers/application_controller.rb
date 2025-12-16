class ApplicationController < ActionController::Base
  allow_browser versions: :modern
  protect_from_forgery with: :null_session

  private

  def authenticate_user!
    auth_header = request.headers["Authorization"] || request.headers["HTTP_AUTHORIZATION"]
    token = auth_header&.split(" ")&.last

    if token
      payload = JwtService.decode(token)
      if payload
        @current_user = User.find_by(id: payload[:user_id])
        return if @current_user
      end
    end

    render json: { error: "Unauthorized" }, status: :unauthorized
  end

  def authorize_admin!
    unless @current_user&.role == "admin"
      render json: { error: "Forbidden - admin access required" }, status: :forbidden
    end
  end
end