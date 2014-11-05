if @mobile
  json.mobile @user.mobile 
else
  json.login @user.username 
end
json.access_token @access_token.token
