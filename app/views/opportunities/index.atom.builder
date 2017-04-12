atom_feed(schema_date: 2016, language: 'en-GB', root_url: @query.feed_root_url) do |feed|
  feed.title t('site_name')
  feed.subtitle 'The demand is out there. You could be too.'
  feed.updated(@query.feed_updated_at) if @query.feed_updated_at
  feed.link(rel: 'prev', href: @query.prev_page, type: 'application/atom+xml') if @query.prev_page?
  feed.link(rel: 'next', href: @query.next_page, type: 'application/atom+xml') if @query.next_page?

  @opportunities.each do |opportunity|
    feed.entry(opportunity, published: opportunity.first_published_at) do |entry|
      entry.title(opportunity.title, type: 'text')
      entry.summary(opportunity.teaser, type: 'text')

      entry.content(type: 'html') do
        xml.cdata! present_html_or_formatted_text(opportunity.description).html_safe
      end

      if opportunity.author && opportunity.author.name
        entry.author do |author|
          author.name(opportunity.author.name)
        end
      end

      opportunity.sectors.each do |sector|
        entry.category('term': sector.slug, 'label': sector.name)
      end
    end
  end
end
