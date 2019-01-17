require 'test_helper'

class DataEncryptingKeyTest < ActiveSupport::TestCase

  test ".generate!" do
    assert_difference "DataEncryptingKey.count" do
      key = DataEncryptingKey.generate!
      assert key
    end
  end
  
  test '#promote!' do
    key = DataEncryptingKey.generate!(primary: true)
    new_key = DataEncryptingKey.generate!
    new_key.promote!
    key.reload
    assert_equal new_key.primary, true
    assert_equal key.primary, false
  end
end
