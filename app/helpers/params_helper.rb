module ParamsHelper

  # Cleans the term parameter
  def clean_term(term = nil)
    term.present? ? term.delete("'").gsub(alphanumeric_words).to_a.join(' ') : ''
  end

  def clean_cpvs(cpvs)
    cpvs = cpvs.join(",") if cpvs.class == Array
    cpvs.present? ? cpvs.gsub(numerics).to_a : []
  end

  # Regex to identify suitable words for term parameter
  def alphanumeric_words
    /([a-zA-Z0-9]*\w)/
  end

  # Regex to identify suitable cpv_ids
  def numerics
    /([0-9]*\w)/
  end

end