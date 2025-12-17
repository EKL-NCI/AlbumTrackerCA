class AuthController < ApplicationController
  skip_before_action :verify_authenticity_token

  # POST /register 
  def register
    user = User.new(user_params)
    user.role ||= "user"

    if user.save
      token = JwtService.encode(user_id: user.id, email: user.email, role: user.role)
      render json: { token: token, user: { id: user.id, email: user.email, role: user.role } }, status: :created
    else
        render json: { errors: user.errors.full_messages },
               status: :unprocessable_entity
    end
  end

  # POST /login
  def login
    user = User.find_by(email: params[:email])

    if user&.authenticate(params[:password])
      token = JwtService.encode(user_id: user.id, email: user.email, role: user.role)
      render json: { token: token, user: { id: user.id, email: user.email, role: user.role } }
    else
        render json: { error: "Invalid email or password" },
               status: :unauthorized
    end
  end

  private

  def user_params
      params.require(:user)
            .permit(:email, :password, :password_confirmation)
    end
  end
end
