require 'aws-sdk-s3'

class S3UploadService
  def initialize
    @s3_client = Aws::S3::Resource.new(
      region: ENV['region'],
      access_key_id: ENV['access_key_id'],
      secret_access_key: ENV['secret_access_key']
    )
    @bucket = ENV['bucket']
  end

  def upload(file, key)
    obj = @s3_client.bucket(@bucket).object(key)
    obj.upload_file(file.path, acl: 'public-read')
    obj.public_url
  end
end
