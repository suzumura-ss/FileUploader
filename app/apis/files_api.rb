module FileUploader
  class FilesAPI < Grape::API
    content_type :txt,  'text/plain'
    content_type :json, 'application/json'
    format :json
    default_format :json

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
        status 302
        s3location = @@bucket.object(content.id).signed_download_uri
        header 'Location', s3location
        {uri:s3location}
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
    end
  end
end
