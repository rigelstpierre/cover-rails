require 'test_helper'

class EncryptedStringTest < ActiveSupport::TestCase

  def setup
    @data_encrypting_key = DataEncryptingKey.generate!(primary: true)
  end

  test '#encrypted_key' do
    encrypted_string = EncryptedString.create(value: 'Mystring')
    assert_equal encrypted_string.encrypted_key, @data_encrypting_key.encrypted_key
  end

  test '#reencrypt!' do
    encrypted_string = EncryptedString.create(value: 'Mystring')
    data_encrypting_key = DataEncryptingKey.generate!(primary: true)
    encrypted_string.reencrypt!(data_encrypting_key)
    assert_equal encrypted_string.encrypted_key, data_encrypting_key.encrypted_key
  end
end
