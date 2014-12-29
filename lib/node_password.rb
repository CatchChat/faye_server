module NodePassword

  def plain_text_to_node_password(plain_text)
    sha256_digest.update(node_salted(plain_text)).hexdigest
  end

  #def check_node_user_id_token(request)
  #  user_node_id, node_token = Base64.decode64(request.headers['X-CatchChatToken']).split(':')
  #  user = User.find_by(node_id: user_node_id, node_token: node_token)
  #end

  def check_node_username_password(username, password)
    node_password = plain_text_to_node_password(password)
    User.find_by(username: username, node_password: node_password)
    # TODO: regenerate encrypted_password using devise
  end

  private
  def sha256_digest
    OpenSSL::Digest.new('sha256')
  end

  def node_salt
    sha256_digest.update('CatchChat').hexdigest
  end

  def node_salted(str)
   max_length = [str.length,node_salt.length].max
   new_str = str.ljust max_length
   new_salt = node_salt.ljust max_length
   new_str.split('').zip(new_salt.split('')).flatten.join.gsub(/\s/, '')
  end
end
