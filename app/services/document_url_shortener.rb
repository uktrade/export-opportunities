class DocumentUrlShortener
  # shorten a url, only accessible to user_id for enquiry_id
  def call(url, user_id, enquiry_id)
    hash_link(url, user_id, enquiry_id)
  end

  def hash_link(url, user_id, enquiry_id)
    d1 = Digest::SHA256.digest([url, user_id, enquiry_id].pack('H*'))
    d2 = Digest::SHA256.digest(d1)
    d2.reverse.unpack('H*').join
  end
end
