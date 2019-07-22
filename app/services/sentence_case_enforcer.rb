class SentenceCaseEnforcer

  #
  # Convert words that are in ALL CAPS to sentence case in the title, teaser and description.
  #
  def initialize(op_params)
    @op_params = op_params
  end

  def call
    @op_params.merge({
      title: enforce_sentence_case(@op_params[:title]),
      teaser: enforce_sentence_case(@op_params[:teaser]),
      description: enforce_sentence_case(@op_params[:description])
    })
  end

  def enforce_sentence_case(string)
    if is_capitalised?(string)
      sentences = PragmaticSegmenter::Segmenter.new(text: string).segment
      string = sentences.map(&:humanize).join(" ")
      string = capitalise_acronyms(string)
    end
    string
  end

  def is_capitalised?(string)
    string == string.upcase
  end

  def capitalise_acronyms(string)
    words = string.split(" ")
    words.map do |word|
      if capitalize?(word.downcase)
        word.capitalize!
      end
      if uppercase?(word.downcase)
        word.upcase!
      end
      word
    end.join(" ")
  end

  def capitalize?(word)
    Word.where(capitalize: true, text: word).any?
  end

  def uppercase?(word)
    Word.where(uppercase: true, text: word).any?
  end

end