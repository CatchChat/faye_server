module NodePassward

  def plain_text_to_node_password(plain_text)
    sha256_digest.update(node_salted(plain_text)).hexdigest
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