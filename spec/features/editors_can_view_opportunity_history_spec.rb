require 'rails_helper'

RSpec.feature 'Editors can view an opportunity’s history' do
  scenario 'seeing status changes' do
    publisher = create(:publisher, name: 'Harrison Bergeron')
    create(:opportunity, title: 'Grand pianos wanted', status: :pending)
    login_as(publisher)

    visit '/admin/opportunities'
    click_on 'Grand pianos wanted'

    expect(page).to have_content t('admin.opportunity.history.unavailable')

    Timecop.freeze(Time.utc(2017, 10, 12, 10, 4, 0)) do
      click_on 'Publish'

      # It's necessary to use page.html/include when asserting on an i18n string
      # with html in it http://stackoverflow.com/a/15993142/751089
      expect(page.html).to include t(
        'admin.opportunity.history.status_changed_html',
        old: 'pending',
        new: 'publish'
      )

      expect(page).to have_text t(
        'admin.opportunity.history.attribution',
        who: 'Harrison Bergeron',
        when: Time.now.utc.to_s(:admin_history)
      )
    end
  end

  scenario 'seeing comments and history in chronological order' do
    publisher = create(:publisher, name: 'Harrison Bergeron')
    create(:opportunity, title: 'Grand pianos wanted', status: :pending)
    login_as(publisher)

    visit '/admin/opportunities'
    click_on 'Grand pianos wanted'

    expect(page).to have_content t('admin.opportunity.history.unavailable')

    fill_in 'Add a comment', with: 'Papa! I am about to publish!'
    click_on 'Add Comment'
    click_on 'Publish'
    fill_in 'Add a comment', with: 'Papa! I have published it!'
    click_on 'Add Comment'

    expect('Papa! I am about to publish!').to appear_before('Papa! I have published it!')
    expect('Status changed').to appear_before('Papa! I have published it!')
  end
end
