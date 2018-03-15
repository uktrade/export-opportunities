class HelpArticlePresenter < BasePresenter
  attr_reader :content, :sections, :id
  attr_accessor :title
  include Rails.application.routes.url_helpers

  def initialize(id, section)
    @id = id
    @section = section || ''
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
    section = text_to_id(heading)
    current_section = section.eql? @section
    @sections.push(id: @id,
                   section: section,
                   heading: heading,
                   content: content,
                   url: admin_help_article_path(@id, section),
                   current: current_section)
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

  def other_articles(article_list)
    others = []
    article_list.each do |article|
      others.push(article) unless article[:id].eql? @id
    end
    others
  end
end
