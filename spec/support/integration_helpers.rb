# alternative to save_and_open_page for capybara css/js rendering
def show_page
  save_page Rails.root.join('public', 'capybara.html')
  `launchy http://localhost:3000/capybara.html`
end
