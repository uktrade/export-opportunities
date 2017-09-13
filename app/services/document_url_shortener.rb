class DocumentUrlShortener
  # shorten a url, only accessible to user_id. we store enquiry id for admin purposes
  def shorten_and_save_link(s3_url, user_id, enquiry_id, original_filename)
    hashed_id = hash_link(s3_url, user_id, enquiry_id)
    save_link(user_id, enquiry_id, original_filename, hashed_id, s3_url)
  end

  def s3_link(user_id, hashed_id)
    unless user_id
      Raven.capture_exception('no user_id found for S3 lookup')
      raise Exception, 'need either one of user or enquiry id as input'
    end

    unless hashed_id
      Raven.capture_exception('need hashed id as input for S3 lookup')
      raise Exception, 'need hashed_id as input' unless hashed_id
    end

    DocumentUrlMapper.where(
      user_id: user_id,
      hashed_id: hashed_id
    ).first
  end

  private

  # Inspired by BTC
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
