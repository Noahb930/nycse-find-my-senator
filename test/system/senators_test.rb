require "application_system_test_case"

class SenatorsTest < ApplicationSystemTestCase
  setup do
    @senator = senators(:one)
  end

  test "visiting the index" do
    visit senators_url
    assert_selector "h1", text: "Senators"
  end

  test "creating a Senator" do
    visit senators_url
    click_on "New Senator"

    fill_in "Beliefs", with: @senator.beliefs
    fill_in "District", with: @senator.district
    fill_in "Email", with: @senator.email
    fill_in "Img", with: @senator.img
    fill_in "Name", with: @senator.name
    fill_in "Party", with: @senator.party
    fill_in "Rating", with: @senator.rating
    fill_in "Url", with: @senator.url
    click_on "Create Senator"

    assert_text "Senator was successfully created"
    click_on "Back"
  end

  test "updating a Senator" do
    visit senators_url
    click_on "Edit", match: :first

    fill_in "Beliefs", with: @senator.beliefs
    fill_in "District", with: @senator.district
    fill_in "Email", with: @senator.email
    fill_in "Img", with: @senator.img
    fill_in "Name", with: @senator.name
    fill_in "Party", with: @senator.party
    fill_in "Rating", with: @senator.rating
    fill_in "Url", with: @senator.url
    click_on "Update Senator"

    assert_text "Senator was successfully updated"
    click_on "Back"
  end

  test "destroying a Senator" do
    visit senators_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Senator was successfully destroyed"
  end
end
