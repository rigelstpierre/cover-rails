class DataEncryptingKey < ActiveRecord::Base

  attr_encrypted :key,
                 key: :key_encrypting_key

  validates :key, presence: true

  def self.primary
    find_by(primary: true)
  end

  def self.generate!(attrs={})
    create!(attrs.merge(key: AES.key))
  end

  def promote!
    transaction do
      DataEncryptingKey.primary.update_attributes!(primary: false)
      update_attributes!(primary: true)
    end
  end

  def key_encrypting_key
    ENV['KEY_ENCRYPTING_KEY']
  end
end

