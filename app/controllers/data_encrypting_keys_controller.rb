class DataEncryptingKeysController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :load_rotate_data_encrypting_key_worker_status, only: [:rotate, :status]
  
  def rotate
    if [:queued, :working].include?(@status)
      render json: { message: 'Key rotation has already been queued.' }, 
             status: :unprocessable_entity
    else
      RotateDataEncryptingKeyWorker.perform_async
      render json: { message: 'Key rotation has been queued' }, status: :ok
    end
  end

  def status
    message = case @status
    when :queued
      'Key rotation has been queued.'
    when :working
      'Key rotation is in progress.'
    else
      'No key rotation queued or in progress.'
    end

    render json: { message: message }, status: :ok
  end

  private

  def load_rotate_data_encrypting_key_worker_status
    @status = Sidekiq::Status::status(Rails.cache.read(:rotate_data_encrypting_key_worker_jid)) 
  end
end