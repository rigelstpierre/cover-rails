require "test_helper"

class DataEncryptingKeysRotationTest < ActionDispatch::IntegrationTest
  def setup
    DataEncryptingKey.generate!(primary: true)
    Rails.cache.clear
  end
  
  def test_rotate
    for i in 0..1000
      post encrypted_strings_url, encrypted_string: { value: "string_#{i}" }
      assert_response :success
    end

    post data_encrypting_keys_rotate_url
    assert_response :success
    
    Sidekiq::Status.stub :status, :queued do
      get data_encrypting_keys_status_url
    end
    assert_response :success
    response = JSON.parse(@response.body)
    assert_equal response['message'], "Key rotation has been queued."
    
    loop do
      get data_encrypting_keys_status_url
      assert_response :success
      response = JSON.parse(@response.body)
      break if response['message'] == 'No key rotation queued or in progress.'
    end
  end
end
