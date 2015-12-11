module FileUploader
  module Logic
    class Bucket
      @@s3 = nil
      def initialize(bucket)
        bucket = $1 if bucket=~/^arn:aws:s3:::(.+)$/
        @@s3 ||= Aws::S3::Resource.new(region: ENV['AWS_REGION'] || 'ap-northeast-1', http_proxy: HTTP_PROXY)
        @bucket = @@s3.bucket(bucket)
      end

      def object(key)
        Object.new(@bucket, key)
      end

      class Object
        def initialize(bucket, key)
          @bucket = bucket
          @object = bucket.object(key)
        end

        def store(tempfile, content_type:'application/octet-stream', metadata:{})
          API.logger.info "upload S3 object: #{@bucket.name}/#{@object.key} type:#{content_type} size:#{tempfile.size}"
          @object.upload_file(tempfile.path, {content_type:content_type, metadata:metadata})
        end

        def destroy!(reason:nil)
          API.logger.info "destroy S3 object: #{@bucket.name}/#{@object.key} #{reason}"
          @object.delete
        end

        def signed_upload_uri(type, size)
          @object.presigned_url(:put, content_type:type, content_length:size)
        end

        def signed_download_uri
          @object.presigned_url(:get)
        end

        def exists?
          @object.exists?
        end

        def metadata
          @object.metadata.with_indifferent_access
        end
      end
    end
  end
end
