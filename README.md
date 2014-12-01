# CatchChat Server

Server side of CatchChat.

## System dependencies

* Ruby 2.1
* Rails 4.1
* MySQL 5.6

## To run the server in local development
1. Install rvm (http://rvm.io/rvm/install)
1. rvm install 2.1
1. install mysql
1. git clone git@github.com:CatchChat/catchchat\_server.git
1. cd catchchat\_server
1. cp config/database.yml.example config/database.yml
1. setup Mysql database username and password and fill in config/database.yml
1. bundle install
1. rake db:create
1. rake db:migrate
1. copy some services setup from tumayun
1. rspec (notes: Run rspec to make sure all tests are passed)
1. rails s
1. access the API at http://localhost:3000


## environments needed for services

```shell
export qiniu_access_key
export qiniu_secret_key
export qiniu_callback_url
export qiniu_callback_body
export upyun_username
export upyun_password
export upyun_form_api_secret
export luosimao_username
export luosimao_apikey
export AWS_ACCESS_KEY_ID
export AWS_SECRET_ACCESS_KEY
export AWS_REGION='cn-north-1'
```

## Status code mapping
http://futureshock-ed.com/2011/03/04/http-status-code-symbols-for-rails/

## git workflow

```bash
# don't merge diretly, instead:

git fetch

git rebase
```

## API HTTP Request Header
### data is submitted as a form
set header:

Content-Type: application/x-www-form-urlencoded

### data is in body as json format
set header:

Content-Type: application/json

```bash
curl -H "Content-Type: application/json" -d '{"login":"ruanwztest","password":"ruanwztest"}

```
## Authenticate

### Login
API use strategies to authenticate the user, there are several ones, their
orders are:

1. token
1. username/password
1. mobile/sms code
1. node username/password

For mobile/sms code, the steps are

1. Client send Post auth/send\_verify\_code with params[:login]=mobile
1. API server create a sms verification code record with user\_id and mobile,
   then send sms token to user
1. Client send auth/create\_by\_mobile with mobile and received sms token
1. API server return an access token

TODO: need to generate new password for user when the node username/password
matched.

### Access token expiration

There are 2 fields in access\_tokens table

1. active
1. expired\_at

For expired\_at, incoming login expiring parameter will be map to expired\_at
field:

1. the value is in seconds
1. expiring=0: never expired, and expired\_at =nil
1. no expiring parameter: expired\_at set to 1 week

### client flag
There is a flag in acces\_tokens table to identify client info

### Change password flow

There are 3 cases when changing password:

1. user already login and remember his old password. he need to input
   current\_password, new\_password, new\_password\_confirm to update the password. API
   server will remove all old access tokens of this user
1. user already login but forget his old password.  
1. user can't login and also forget his old password.


In the last 2 cases, the steps are

1. by Post passwords/send\_verify\_code, Client request to send a token to the mobile, then create an SmsVerificationCode
1. After receive the sms token, client send to Post passwords/change\_password with
   mobile, token and new/confirmed password
1. API server verify the token and reset the password
1. API server remove all old access\_tokens

### Register new user

To register a new user, there are 2 steps
1. User input the required info: username, password, mobile
2. API verify the user info and create the user record, then send sms token to user
3. User input the sms token
4. API check the sms token and set the user status to be active

  
## Paginate
Use gem Kaminari 

Default to 30 records per page, page number starts from 1

## Attachment
There are 3 providers for the attachment:

1. qiniu
1. upyun
1. s3

Some testing show that the DNS resolving for qiniu is slow, and it seems s3 has
the best speed.

To upload attachment:

1. client send to api the bucket name, file name(some uuid), storage provider , and get the upload token(or upload url)
1. client upload the file to storage provider
1. storage notice API server or API server query the storage the completed
   filename.
1. API server update the message object with storage url/key, then push to the
   recipient

To download attachment:

1. client send to the api the bucket name, file name, storage provider, and get
   the download token(or download url)
1. client use the download token to download file from storage provider




