class HelpArticlePresenter < BasePresenter
  attr_reader :content, :related_links, :sections, :title, :url

  def initialize(url, section_id="")
    @section_id = section_id
    @url = url
    @related_links = Array.new
    @sections = Array.new
  end

  def text_to_id(str="")
    str = str.gsub(" ", "-")
    str = str.gsub(/[^0-9a-z-]/i, '')
    str.downcase
  end

  def set_title(title="")
    @title = title
  end

  def set_related_link(text, href)
    @related_links.push({
      :text => text,
      :href => href
    })
  end
 
  def set_section(heading="", content="")
    section_id = text_to_id(heading)
    @sections.push({
      :id => section_id,
      :heading => heading,
      :content => content,
      :url => "/%s/%s" % [@url, section_id],
      :current => (section_id.eql? @section_id) ? true : false 
    }) 
  end

  def current_section
    section = @sections[0]
    @sections.each do |s|
      if s[:current]
        section = s
      end
    end
    return section
  end

  def pagination
    links = {}
    index = @sections.find_index(current_section)

    # previous section
    p = index - 1
    if p >= 0
      links[:previous] = @sections[p]
    end

    # next section
    n = index + 1
    if n < @sections.length
      links[:next] = @sections[n]
    end

    return links
  end

end


1
