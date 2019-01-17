class EncryptedString < ActiveRecord::Base
  belongs_to :data_encrypting_key

  attr_encrypted :value,
                 mode: :per_attribute_iv_and_salt,
                 key: :encrypted_key

  validates :token, presence: true, uniqueness: true
  validates :data_encrypting_key, presence: true
  validates :value, presence: true

  before_validation :set_token, :set_data_encrypting_key

  def encrypted_key
    self.data_encrypting_key ||= DataEncryptingKey.primary
    data_encrypting_key.encrypted_key
  end

  def reencrypt!(new_key)
    update_attributes!(data_encrypting_key: new_key, value: value)
  end

  private

  def encryption_key
    self.data_encrypting_key ||= DataEncryptingKey.primary
    data_encrypting_key.key
  end

  def set_token
    begin
      self.token = SecureRandom.hex
    end while EncryptedString.where(token: self.token).present?
  end

  def set_data_encrypting_key
    self.data_encrypting_key ||= DataEncryptingKey.primary
  end
end
