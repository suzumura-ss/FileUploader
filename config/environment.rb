FileUploader::FilesAPI.bucket = ENV['BUCKET_ARN']

FileUploader::FilesAPI.x_accel_redirect = nil # use X-Accel-Redirect unless nil
FileUploader::FilesAPI.x_reproxy_url = false  # use X-Reproxy-URL if true
=begin
    | x_accel_redirect  | x_reproxy_url |
    | nil               | false         | 302 + Location header
    | "/reploxy"        | false         | mount s3bucket to "/reploxy" .
    | nil               | true          | process X-Reproxy-URL header with Apache::mod_reproxy.
    | "/reproxy"        | true          | process X-Reproxy-URL header with nginx.

location /reploxy {
    internal;
    resolver 8.8.8.8;
    set $reproxy  $upstream_http_x_reproxy_url;
    proxy_pass $reproxy;
}
=end
