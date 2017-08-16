class DocumentUrlShortener
  # shorten a url, only accessible to user_id for enquiry_id
  def shorten_link(s3_url, user_id, enquiry_id, original_filename)
    hashed_id = hash_link(s3_url, user_id, enquiry_id)
    save_link(user_id, enquiry_id, original_filename, hashed_id, s3_url)
  end

  def s3_link(user_id, enquiry_id, original_filename)
    raise Exception, 'need either one of user or enquiry id as input' unless user_id || enquiry_id
    raise Exception, 'need filename as input' unless original_filename

    DocumentUrlMapper.where(
      user_id: user_id,
      enquiry_id: enquiry_id,
      original_filename: original_filename
    ).first
  end

  def hash_link(s3_url, user_id, enquiry_id)
    d1 = Digest::SHA256.digest([s3_url, user_id, enquiry_id].pack('H*'))
    d2 = Digest::SHA256.digest(d1)
    d2.reverse.unpack('H*').join
  end

  def save_link(user_id, enquiry_id, original_filename, hashed_id, s3_url)
    DocumentUrlMapper.create!(
      user_id: user_id,
      enquiry_id: enquiry_id,
      original_filename: original_filename,
      hashed_id: hashed_id,
      s3_link: s3_url
    )
  end
end
