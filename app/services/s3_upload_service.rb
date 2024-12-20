require 'aws-sdk-s3'
require 'logger'

class S3UploadService
  def initialize
    @s3_client = Aws::S3::Resource.new(
      region: ENV['region'],
      access_key_id: ENV['access_key_id'],
      secret_access_key: ENV['secret_access_key']
    )
    @bucket = ENV['bucket']
    @logger = Logger.new(STDOUT) # You can configure a log file here if needed
  end

  def upload(file, key)
    raise ArgumentError, 'File cannot be nil' if file.nil?
    raise ArgumentError, 'Key cannot be nil or empty' if key.nil? || key.strip.empty?

    obj = @s3_client.bucket(@bucket).object(key)
    @logger.info("Starting upload to S3: bucket=#{@bucket}, key=#{key}")

    begin
      obj.upload_file(file.path, acl: 'public-read')
      @logger.info("Upload successful: #{obj.public_url}")
      obj.public_url
    rescue Aws::S3::Errors::ServiceError => e
      @logger.error("S3 service error: #{e.message}")
      raise "Failed to upload file to S3: #{e.message}"
    rescue Errno::ENOENT => e
      @logger.error("File not found: #{e.message}")
      raise "File not found: #{e.message}"
    rescue StandardError => e
      @logger.error("Unexpected error during S3 upload: #{e.message}")
      raise "An unexpected error occurred during the upload: #{e.message}"
    end
  end
end
