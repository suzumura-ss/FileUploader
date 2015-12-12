require 'open-uri'


module FileUploader
  class ReesponseStreamer
    def initialize(uri)
      @uri = uri
    end
    def each(&block)
      Kernel.open(@uri){|res|
        res.each(&block)
      }
    end
  end

  class FilesAPI < Grape::API
    content_type :txt,  'text/plain'
    content_type :json, 'application/json'
    format :json
    default_format :json

    @@x_reproxy_url = false
    def self.x_reproxy_url=(flag)
      @@x_reproxy_url = flag
    end

    @@x_accel_redirect = nil
    def self.x_accel_redirect=(s3mountpoint)
      @@x_accel_redirect = s3mountpoint
    end

    @@redirect_with_location = false
    def self.redirect_with_location=(flag)
      @@redirect_with_location = flag
    end

    def self.bucket=(bucket)
      @@bucket = Logic::Bucket.new(bucket)
    end

    resource :files do

      before do
        @user_id = Logic.validate_user_id(request.env['HTTP_AUTHORIZATION'])
        @user_id ||= Logic.validate_user_id(request.env['HTTP_X_AUTHORIZATION'])
        @user_id ||= 'guest'
        raise AuthorizationRequired unless @user_id
      end

      params do
        requires :comment,  type: String
        requires :body,     type: File
      end
      post '' do
        id = UUID.generate
        metadata = {name:params.body.filename, comment:params.comment}
        @@bucket.object(id).store(params.body.tempfile, content_type:params.body.type, metadata:metadata)
        begin
          content = Content.create(id:id, user_id:@user_id)
        rescue => e
          @@bucket.object(id).destroy!(reason:"#{e.inspect}")
          raise e
        end
        status 201
        {id:content.id}
      end

      params do
        requires :id, type: String
      end
      get ':id' do
        content = Content.where(id:params.id).where(user_id:@user_id).take!
        s3obj = @@bucket.object(content.id)
        s3location = s3obj.signed_download_uri
        if @@x_reproxy_url or @@x_accel_redirect
          status 200
          content_type s3obj.content_type
          if @@x_reproxy_url
            header 'X-Reproxy-URL', s3location
            header 'X-Accel-Redirect', "/#{@@x_accel_redirect}"
          else
            header 'X-Accel-Redirect', "/#{@@x_accel_redirect}/#{content.id}"
          end
          ""
        elsif @@redirect_with_location
          status 302
          header 'Location', s3location
          {uri:s3location}
        else
          status 200
          content_type s3obj.content_type
          file ReesponseStreamer.new(s3location)
        end
      end

      params do
        requires :id, type: String
      end
      get ':id/metadata' do
        content = Content.where(id:params.id).where(user_id:@user_id).take!
        status 200
        @@bucket.object(content.id).metadata
      end

      params do
        requires :id, type: String
      end
      delete ':id' do
        content = Content.where(id:params.id).where(user_id:@user_id).take!
        content.destroy!
        @@bucket.object(content.id).destroy!
        status 200
        {state:'deleted'}
      end

      get '' do
        status 200
        Content.where(user_id:@user_id).find_each.inject([]){|s,c|
          s << c.id
          s
        }
      end
    end
  end
end
