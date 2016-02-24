# -*- coding: utf-8 -*-
# EDSC-137: As a user, I want an introductory tour when I visit the site so I
#           may quickly get oriented in the system

require "spec_helper"

# Resetting here because the tour introduces very complex page state that's not easy to back out of
describe "Site tour", reset: true do
  after :each do
    wait_for_xhr
    User.destroy_all if page.server.responsive?
  end

  context "on the landing page" do
    before :each do
      Capybara.reset_sessions!
      visit "/" # Load the root url with no extra params
      wait_for_xhr
    end

    # Single spec for the tour which tests every stop.  Normally I'd like this to be separate tests per stop, but
    # doing so is slow and highly redundant because the tour is so serial.
    it "shows an introductory tour walking the user through finding and visualizing data and adding it to a project" do
      expect(page).to have_popover('Welcome to Earthdata Search')
      click_on 'Next'

      expect(page).to have_popover('Keyword Search')
      fill_in 'keywords', with: 'snow cover nrt'
      click_on 'Browse All Data'

      expect(page).to have_popover('Browse Collections')
      find_link('Platform').click

      expect(page).to have_popover('Browse Collections')
      find(".facets-item", text: "Aqua").click
      wait_for_xhr

      expect(page).to have_popover('Spatial Search')
      create_bounding_box(0, 0, 10, 10)
      wait_for_xhr

      expect(page).to have_popover('Collection Results')
      fourth_collection_result.click

      expect(page).to have_popover('Matching Granules')
      second_granule_list_item.click

      expect(page).to have_popover('Map View')
      page.find('.leaflet-control-layers').trigger(:mouseover)

      expect(page).to have_popover('Map View')
      choose 'Land / Water Map'

      expect(page).to have_popover('Granule Timeline (Part 1)')
      find('.timeline-zoom-in').click

      expect(page).to have_popover('Granule Timeline (Part 2)')
      click_timeline_date('24', 'Aug')

      expect(page).to have_popover('Granule Timeline (Part 3)')
      drag_temporal(DateTime.new(2014, 8, 23, 0, 0, 0, '+0'), DateTime.new(2015, 8, 25, 0, 0, 0, '+0'))

      expect(page).to have_popover('Back to Collections')
      granule_list.click_on 'Back to Collections'

      expect(page).to have_popover('Comparing Multiple Collections')
      second_collection_result.find('.add-to-project').click

      expect(page).to have_popover('Projects')
      click_on 'View Project'

      expect(page).to have_popover('Project (cont.)')
    end

    context 'clicking on the tour\'s "End Tour" button' do
      before :each do
        click_on 'End Tour'
      end

      it 'shows a popover indicating that the tour ended with information on how to restart it' do
        expect(page).to have_popover('Tour Ended')
      end

      context 'and closing the tour ended dialog' do
        before :each do
          click_on 'Close'
        end

        it 'shows no further popovers' do
          expect(page).to have_no_popover
        end
      end
    end

    context "starting the tour and searching for terms other than those prompted by the tour" do
      before :each do
        click_on 'Next'
        expect(page).to have_popover
        fill_in "keywords", with: "AST_L1A"
        click_on 'Browse All Data'
      end

      it "hides the tour" do
        expect(page).to have_no_popover
      end
    end

    context "starting a search without starting the tour" do
      before :each do
        click_on 'Browse All Data'
      end

      it "hides the tour" do
        expect(page).to have_no_popover
      end
    end
  end

  context "directly loading the search page" do
    before :each do
      load_page :search, overlay: false
    end

    it "shows no tour" do
      expect(page).to have_no_popover
    end
  end
end
