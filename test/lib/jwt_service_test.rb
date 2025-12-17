require "test_helper"

class JwtServiceTest < ActiveSupport::TestCase
  test "encodes and decodes payload" do
    # Create a sample payload
    payload = { user_id: 1, role: "admin" }
    token = JwtService.encode(payload)
    decoded = JwtService.decode(token)

    # Verify that the decoded payload matches the original
    assert_equal payload[:user_id], decoded[:user_id]
    assert_equal payload[:role], decoded[:role]
  end
end
