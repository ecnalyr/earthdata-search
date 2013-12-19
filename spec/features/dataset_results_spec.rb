require "spec_helper"

describe "Dataset results" do
  before do
    visit "/"
    # scrolling in these specs doesn't work unless the window is resized
    page.driver.resize_window(1000, 1000)
  end

  shared_browser_session do
    it "displays the first 10 datasets when first visiting the page" do
      expect(page).to have_css('#dataset-results .panel-list-item', count: 10)
    end

    it "loads more results when the user scrolls to the bottom of the current list" do
      page.execute_script "$('#dataset-results .master-overlay-content')[0].scrollTop = 10000"
      expect(page).to have_css('#dataset-results .panel-list-item', count: 20)
    end

    it "does not load additional results after all results have been loaded" do
      fill_in "keywords", with: "AST"
      expect(page).to have_css('#dataset-results .panel-list-item', count: 10)
      page.execute_script "$('#dataset-results .master-overlay-content')[0].scrollTop = 10000"
      expect(page).to have_css('#dataset-results .panel-list-item', count: 20)
      page.execute_script "$('#dataset-results .master-overlay-content')[0].scrollTop = 10000"
      expect(page).to have_css('#dataset-results .panel-list-item', count: 22)
      expect(page).to have_no_content('Loading datasets...')
    end

    it "hides and shows facets" do
      expect(page).to have_css('.master-overlay-hide-parent')
      click_link 'Hide Facets'
      expect(page).to have_css('.master-overlay-show-parent')
      click_link 'Show Facets'
      expect(page).to have_css('.master-overlay-hide-parent')
    end
  end

end