if @success
  json.mobile @mobile
  json.status 'sms sent' 
else
  json.mobile @mobile
  json.status 'failed' 
end
