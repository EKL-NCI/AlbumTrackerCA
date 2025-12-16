module Api
  class SessionsController < ApplicationController
    def create
      user = User.find_by(email: params[:email])

      if user&.authenticate(params[:password])
        token = JwtService.encode(user_id: user.id, role: user.role)
        render json: { token: token }, status: :ok
      else
        render json: { error: 'Invalid credentials' }, status: :unauthorized
      end
    end
  end
end