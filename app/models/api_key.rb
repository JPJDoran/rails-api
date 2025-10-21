class ApiKey < ApplicationRecord
  before_create :generate_token

  validates :token, uniqueness: true

  private

  def generate_token
    self.token = SecureRandom.hex(32)
  end
end