class User < ApplicationRecord
  # Test
  has_secure_password

  validates :email, presence: true, uniqueness: true
  validates :role, inclusion: { in: %w[user admin] }

  # Set default role as 'user'
  after_initialize :set_default_role, if: :new_record?

  def set_default_role
    self.role ||= "user"
  end
end
