require "test_helper"

class JwtServiceTest < ActiveSupport::TestCase
  test "encodes and decodes payload" do
    payload = { user_id: 1, role: "admin" }
    token = JwtService.encode(payload)
    decoded = JwtService.decode(token)

    assert_equal payload[:user_id], decoded[:user_id]
    assert_equal payload[:role], decoded[:role]
  end
end