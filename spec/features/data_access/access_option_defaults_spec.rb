require "spec_helper"

# Reset because this spec is heavily dependent on the database, which gets
# cleared between runs
describe "Access Option Defaults", reset: true do
  dataset_id = 'C90762182-LAADS'

  before :each do
    load_page :search, overlay: false
    login
  end

  after :each do
    wait_for_xhr
    AccessConfiguration.destroy_all if page.server.responsive?
  end

  context "accessing a dataset for the first time" do
    before :each do
      load_page 'data/configure', project: [dataset_id]
      wait_for_xhr
    end

    it "presents default options" do
      expect(page).to have_unchecked_field('Download')
      expect(page).to have_unchecked_field('FtpPushPull')
    end
  end

  context "accessing a dataset for a second time" do
    before :each do
      load_page 'data/configure', project: [dataset_id]
      wait_for_xhr

      choose 'Download'
      click_on 'Add access method'

      within '.access-item-selection:nth-child(4)' do
        choose 'FtpPushPull'
      end

      select 'FtpPull', from: 'Distribution Options'

      click_on 'Continue'
      click_on 'Submit'
      expect(page).to have_content('Not Validated')

      load_page 'data/configure', project: [dataset_id]
      wait_for_xhr
    end

    it "restores options from the second retrieval" do
      within '.access-item-selection:nth-child(1)' do
        expect(page).to have_checked_field('Download')
        expect(page).to have_unchecked_field('FtpPushPull')
      end

      within '.access-item-selection:nth-child(4)' do
        expect(page).to have_unchecked_field('Download')
        expect(page).to have_checked_field('FtpPushPull')
      end

      expect(page).to have_select('Distribution Options', selected: 'FtpPull')
    end
  end

  context "accessing a dataset for the third time" do
    before :each do
      load_page 'data/configure', project: [dataset_id]
      wait_for_xhr

      choose 'Download'
      click_on 'Add access method'

      within '.access-item-selection:nth-child(4)' do
        choose 'FtpPushPull'
      end

      select 'FtpPull', from: 'Distribution Options'

      click_on 'Continue'
      click_on 'Submit'
      expect(page).to have_content('Not Validated')

      load_page 'data/configure', project: [dataset_id]
      wait_for_xhr

      within '.access-item-selection:nth-child(4)' do
        click_on 'Remove access method'
      end

      click_on 'Submit'
      expect(page).to have_link('View Download Links')
      expect(page).to have_no_link('Not Validated')

      load_page 'data/configure', project: [dataset_id]
      wait_for_xhr
    end

    it "restores options from the second retrieval" do
      expect(page).to have_css('.access-item-selection', count: 1)
      expect(page).to have_checked_field('Download')
      expect(page).to have_unchecked_field('FtpPushPull')
    end
  end

end
