# config/initializers/carrierwave.rb
CarrierWave.configure do |config|
  if Rails.env.production?
    config.storage = :fog
    config.fog_provider = 'fog/aws'
    config.fog_credentials = {
      provider:              'AWS',
      aws_access_key_id:     Rails.application.credentials.aws_s3[:access_key_id],
      aws_secret_access_key: Rails.application.credentials.aws_s3[:secret_access_key],
      region:                'ap-northeast-1'
    }
    config.fog_directory  = 'morning-forest'
    config.fog_public     = true
  else
    config.storage = :file
  end
end
