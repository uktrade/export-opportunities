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
  # Unmatched markers (not enough arguments) leave the
  # inclusion markers in place.
  #
  # e.g. Returns string "Hello Darth Vader"
  # when
  # content = "Hello [$first_name] [$last_name]"
  # and
  # includes = ["Darth", "Vader"]
  #
  # e.g. Returns string "Hello Darth [$last_name]"
  # when
  # content = "Hello [$first_name] [$last_name]"
  # and
  # includes = ["Darth"]
  #
  # e.g. Returns string "Hello  Vader"
  # when
  # content = "Hello [$first_name] [$last_name]"
  # and
  # includes = ["", "Vader"]
  #
  # The inclusion markers first_name and last_name are irrelevant
  # and only need be used to help understand what content will
  # be injected.
  #
  # e.g. Returns string "Hello Darth Vader"
  # when
  # content = "Hello [$first_name] [$last_name]"
  # or
  # content = "Hello [$anything_here] [$whatever]"
  # and
  # includes = ["Darth", "Vader"]
  #
  def content_with_inclusion(key, includes)
    str = @content[key] || ''
    includes.each do |include|
      str = str.sub(/\[\$.+?\]/, include)
    end
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
    str = @content[key] || ''
    str.gsub(/\[\$.+?\]/, '').gsub(/\s+/, ' ').html_safe
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

  private

  def create_breadcrumbs
    [
      { title: 'Home', slug: 'https://www.great.gov.uk/' },
      { title: 'Export Opportunities', slug: '/' },
    ]
  end
end
