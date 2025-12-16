class JwtService
  # Jwt Secret Key
  JWT_SECRET_KEY = Rails.application.secret_key_base

  def self.encode(payload)
    payload[:exp] = 24.hours.from_now.to_i
    JWT.encode(payload, JWT_SECRET_KEY, "HS256")
  end

  def self.decode(token)
    decoded = JWT.decode(
      token,
      JWT_SECRET_KEY,
      true,
      algorithm: "HS256"
    ).first

    HashWithIndifferentAccess.new(decoded)
  rescue JWT::DecodeError, JWT::ExpiredSignature
    nil
  end
end
