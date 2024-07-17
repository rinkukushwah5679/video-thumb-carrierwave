require 'mime/types'
class VideoUploader < CarrierWave::Uploader::Base
  # Include RMagick or MiniMagick support:
  # include CarrierWave::RMagick
  include CarrierWave::MiniMagick
  include CarrierWave::Video  # for your video processing
  include CarrierWave::Video::Thumbnailer
  include CarrierWave::FFmpeg
  # Choose what kind of storage to use for this uploader:
  storage :aws
  # storage :fog

  # Override the directory where uploaded files will be stored.
  # This is a sensible default for uploaders that are meant to be mounted:
  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  # Provide a default URL as a default if there hasn't been a file uploaded:
  # def default_url(*args)
  #   # For Rails 3.1+ asset pipeline compatibility:
  #   # ActionController::Base.helpers.asset_path("fallback/" + [version_name, "default.png"].compact.join('_'))
  #
  #   "/images/fallback/" + [version_name, "default.png"].compact.join('_')
  # end

  # Process files as they are uploaded:
  # process scale: [200, 300]
  #
  # def scale(width, height)
  #   # do something
  # end
  version :video, :if => :video? do
    process :encode
  end
  # Create different versions of your uploaded files:
  version :thumb do
    process thumbnail: [{format: 'jpg', quality: 85, size: 400, strip: true, logger: Rails.logger}]
    def full_filename for_file
      jpg_name for_file, version_name
    end
  end

  version :medium do
    process thumbnail: [{format: 'jpg', quality: 85, size: 400, strip: false, logger: Rails.logger}]
    def full_filename for_file
      jpg_name for_file, version_name
    end
  end
  def encode
    video = FFMPEG::Movie.new(@file.path)
    video_transcode = video.transcode(@file.path)
  end

  def jpg_name for_file, version_name
    %Q{#{version_name}_#{for_file.chomp(File.extname(for_file))}.jpg}
  end
  version :thumb, :if => :is_image?  do
    process resize_to_fit: [450, 400]
  end

  protected
    def is_image?(resource_file)
      content_type = resource_file.content_type
      extentions = %w(image/jpeg image/png image/jpg image/gif)
      extentions.include? content_type
    end
    def video?(resource_file)
      content_type = resource_file.content_type
      extentions = %w(video/mp4 video/ogv video/ogg video/mov video/quicktime audio/ogg)
      extentions.include? content_type
    end
  # Add an allowlist of extensions which are allowed to be uploaded.
  # For images you might use something like this:
  # def extension_allowlist
  #   %w(jpg jpeg gif png)
  # end

  # Override the filename of the uploaded files:
  # Avoid using model.id or version_name here, see uploader/store.rb for details.
  # def filename
  #   "something.jpg" if original_filename
  # end
end
