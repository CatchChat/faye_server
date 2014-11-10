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
