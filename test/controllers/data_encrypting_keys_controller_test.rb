require 'test_helper'

class DataEncryptingKeysControllerTest < ActionController::TestCase

  def setup
    @data_encrypting_key = DataEncryptingKey.generate!(primary: true)
  end

  test 'POST #rotate schdules key rotation' do
    post :rotate
    assert_response :success

    json = JSON.parse(response.body)
    assert_equal json['message'], 'Key rotation has been queued'
  end

  test 'POST #rotate returns error if key rotation has already been queued' do   
    Sidekiq::Status.stub :status, :queued do
      post :rotate
    end
    assert_response :unprocessable_entity

    json = JSON.parse(response.body)
    assert_equal json['message'], 'Key rotation has already been queued.'
  end

  test 'POST #rotate returns error if key rotation is working' do   
    Sidekiq::Status.stub :status, :working do
      post :rotate
    end
    assert_response :unprocessable_entity

    json = JSON.parse(response.body)
    assert_equal json['message'], 'Key rotation has already been queued.'
  end

  test 'GET #status returns queued if job is queued' do
    Sidekiq::Status.stub :status, :queued do
      get :status
    end
    assert_response :ok

    json = JSON.parse(response.body)
    assert_equal json['message'], 'Key rotation has been queued.'
  end

  test 'GET #status returns working if job is working' do
    Sidekiq::Status.stub :status, :working do
      get :status
    end
    assert_response :ok

    json = JSON.parse(response.body)
    assert_equal json['message'], 'Key rotation is in progress.'
  end

  test 'GET #status returns no key rotation if job is not queued or working' do
    get :status
    assert_response :ok

    json = JSON.parse(response.body)
    assert_equal json['message'], 'No key rotation queued or in progress.'
  end
end