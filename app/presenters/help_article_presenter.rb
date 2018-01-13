class HelpArticlePresenter < BasePresenter
  attr_reader :content, :sections, :title

  def initialize(article_id="", section_id="")
    @article_id = id_to_file(article_id)
    @section_id = section_id
    @content = "admin/help/%s" % [@article_id]
    @sections = Array.new
  end
 
  def id_to_file(str="")
    str = str.gsub "-", "_"
    str.gsub(/[^0-9a-z] /i, '')
  end

  def text_to_id(str="")
    str = str.gsub(" ", "-")
    str = str.gsub(/[^0-9a-z-]/i, '')
    str.downcase
  end

  def set_title(title="")
    @title = title
  end

  def set_section(heading="", content="")
    id = text_to_id(heading)
    @sections.push({
      :id => id,
      :heading => heading,
      :content => content,
      :url => "/%s/%s" % [@content, id] 
    }) 
  end

  def current_section
    section = @sections[0]
    @sections.each do |s|
      if s[:id].eql? @section_id
        section = s
      end
    end
    return section
  end

end
