FileUploader
===============

## launch

    $ export AWS_ACCESS_KEY_ID="..."
    $ export AWS_SECRET_ACCESS_KEY="..."
    $ export AWS_REGION="ap-northeast-1"
    $ export RDS_HOSTNAME="your-rds-db-host"
    $ export RDS_PORT="your-rds-db-port"
    $ export RDS_DB_NAME="your-rds-db-name"
    $ export RDS_USERNAME="your-rds-db-username"
    $ export RDS_PASSWORD="your-rds-db-password"
    $ #export HTTPS_PROXY="http://your-proxy-host:8080/"
    $ export BUCKET_ARN="arn:aws:s3:::your-s3-bucket"
    $ rackup


## upload

    $ curl localhost:9292/files -F "comment=hello,world" -F "body=@Gemfile;type=text/plain"
    {"id":"uuid-string"}


## download

    $ curl -L localhost:9292/files/uuid-string
    (file body)


## metadata

    $ curl localhost:9292/files/uuid-string
    {"name":"Gemfile","comment":"hello,world"}


## delete

    $ curl localhost:9292/files/uuid-string
    {"state":"deleted"}
