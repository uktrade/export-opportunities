class PagePresenter < BasePresenter
  attr_reader :breadcrumbs

  def initialize(content)
    @content = content
    @breadcrumbs = create_breadcrumbs
    add_breadcrumb_current(content['breadcrumb_current']) if content.present?
  end

  # Gets content by either single 'key' value
  # or nested 'key.is.here' value.
  def content(key_path)
    keys = key_path.split('.')
    content = @content
    keys.each do |key|
      break unless content.key? key
      content = content[key]
    end
    content.class == String ? content : ''
  end

  # Injects values into a formatted string.
  # You can includes conditional content by surrounding
  # your inclusion marker labels.
  #
  # [$something] = Inclusion marker
  # $something = Inclusion marker label ('something' can be any word, it is not matched)
  # [some $label content ] = Inclusion marker with conditional content.
  #
  # The conditional content above is 'some ' and ' content ' (spaces included).
  #
  #
  # EXMPLES WITHOUT CONDITIONAL CONTENT in the inclusion markers
  # ------------------------------------------------------------
  #
  # E.g.
  # content = "Hello [$first_name] [$last_name]"
  #
  # Returns string "Hello Darth Vader"
  # when includes = ["Darth", "Vader"]
  #
  # Returns string "Hello Darth"
  # when includes = ["Darth"]
  #
  # Returns string "Hello Vader"
  # when includes = ["", "Vader"]
  #
  #
  # EXAMPLES TO SHOW THE LABEL NAMES ARE IRRELEVANT
  # -----------------------------------------------
  # The inclusion marker label names/wording is irrelevant.
  # first_name and last_name are only helpful in these examples
  # to show what is expected to be injected in the content.
  # The content in this example contains confusing names but
  # would work exactly the same as the other examles, given
  # the same data.
  #
  # E.g.
  # content = "Hello [$building] [$spaceman]"
  #
  # Returns string "Hello Darth Vader"
  # when includes = ["Darth", "Vader"]
  #
  #
  # EXAMPLES WITH CONDITIONAL CONTENT in the inclusion markers
  # ----------------------------------------------------------
  # You can also include conditional content that shows only when a match is found.
  # The conditional content can be put around the target inclusion marker label.
  # Some examples will explain better than words.
  #
  # E.g.
  # content = 'Has [an $foo or ][a $bar and ]a dream'
  #
  # Returns 'Has a dream'
  # when includes = []
  #
  # Returns 'Has an idea or a dream'
  # when includes = ['idea', '']
  #
  # Returns 'Has a plan and a dream'
  # when includes = ['', 'plan']
  #
  # Returns 'Has an idea or a plan and a dream'
  # when includes = ['idea', 'plan']
  #
  def content_with_inclusion(key, includes)
    str = @content[key] || ''
    re = /\[([^\[\]]*?)\$[a-z]+[\w_]*([^\[\]]*?)\]/i
    includes.each do |include|
      str.sub(re, '') # TODO: Why does it work with this line but not without?
      # re.match(str)   # This one also makes it work !?!?!
      str = if include.present?
              str.sub(re, "#{Regexp.last_match(1)}#{include}#{Regexp.last_match(2)}")
            else
              str.sub(re, '') # just remove the inclusion marker
            end
    end
    str = str.gsub(re, '') # If includes was empty
    str.gsub(/\s+/, ' ').html_safe
  end

  # Similar to content_with_inclusion but replaces all
  # inclusion markers with blank '' string.
  #
  # e.g. Returns string "Hello  "
  # when
  # str = "Hello [$first_name] [$second_name]"
  #
  def content_without_inclusion(key)
    content_with_inclusion(key, [])
  end

  def create_trade_profile_url(number = '')
    if number.blank?
      Figaro.env.TRADE_PROFILE_CREATE_WITHOUT_NUMBER
    else
      "#{Figaro.env.TRADE_PROFILE_CREATE_WITH_NUMBER}#{number}"
    end
  end

  def add_breadcrumb_current(title)
    @breadcrumbs.push(title: title, slug: '') unless title.nil?
  end

  def highlight_words(content, words)
    words.reverse.each do |word|
      content = content.gsub(Regexp.new("\\b#{word}\\b", 'i'), content_tag('span', word, class: 'highlight'))
    end
    content.html_safe
  end

  private

  def create_breadcrumbs
    [
      { title: 'Home', slug: 'https://www.great.gov.uk/' },
      { title: 'Export Opportunities', slug: '/' },
    ]
  end
end
