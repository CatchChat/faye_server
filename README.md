# CatchChat Server

Server side of CatchChat.

## System dependencies

* Ruby 2.1
* Rails 4.1
* MySQL 5.6

## environments needed for services

```shell
export qiniu_access_key
export qiniu_secret_key
export upyun_username
export upyun_password
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

## Authenticate

### Login
API use strategies to authenticate the user, there are several ones, their
orders are:

1. token
1. username/password
1. mobile/sms code
1. node username/password

TODO: need to generate new password for user when the node username/password
matched.

### Access token expiration
There are 2 fields in access\_tokens table
1. active
1. expired\_at

For expired\_at, incoming login expiring parameter will be map to expired\_at
field:
1. the value is in seconds
1. expiring: 0: never expired
1. no expiring parameter: default to 1 week


