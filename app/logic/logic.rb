require_relative 'bucket_logic'

module FileUploader
  module Logic
    HTTP_PROXY = ENV['HTTP_PROXY'] || ENV['HTTPS_PROXY']

    def self.validate_user_id(token)
      # ToDo: test authorization signature.
      user_id, signature = (token || '').split(/:/, 2)
      user_id
    end
  end
end
