class HelpArticlePresenter < BasePresenter
  attr_reader :content, :related_links, :sections, :url
  attr_accessor :title

  def initialize(url, section_id = '')
    @section_id = section_id
    @url = url
    @related_links = []
    @sections = []
  end

  def text_to_id(str = '')
    str = str.tr('', '-')
    str = str.gsub(/[^0-9a-z-]/i, '')
    str.downcase
  end

  def set_related_link(text, href)
    @related_links.push(
      text: text,
      href: href
    )
  end

  def set_section(heading = '', content = '')
    section_id = text_to_id(heading)
    current_section_id = section_id.eql? @section_id
    @sections.push(id: section_id,
                   heading: heading,
                   content: content,
                   url: format('/%s/%s', @url, section_id),
                   current: current_section_id)
  end

  def current_section
    section = @sections[0]
    @sections.each do |s|
      section = s if s[:current]
    end
    section
  end

  def pagination
    links = {}
    index = @sections.find_index(current_section)

    # previous section
    p = index - 1
    links[:previous] = @sections[p] if p >= 0

    # next section
    n = index + 1
    links[:next] = @sections[n] if n < @sections.length

    links
  end
end
1
