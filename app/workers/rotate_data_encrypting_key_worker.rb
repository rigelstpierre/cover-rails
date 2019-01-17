class RotateDataEncryptingKeyWorker
  include Sidekiq::Worker
  include Sidekiq::Status::Worker

  def perform(*args)
    Rails.cache.write(:rotate_data_encrypting_key_worker_jid, self.jid)
    current_key = DataEncryptingKey.primary
    new_key = DataEncryptingKey.generate!(primary: true)
    new_key.promote!
    reencrypt_encrypted_string(current_key, new_key)
  end
  
  private

  def reencrypt_encrypted_string(current_key, new_key)
    encrypted_strings = EncryptedString.where(data_encrypting_key_id: current_key.id)
    encrypted_strings.each do |encrypted_string|
      encrypted_string.reencrypt!(new_key)
    end
  end
end
