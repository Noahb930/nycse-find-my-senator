require 'test_helper'

class DonationsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @donation = donations(:one)
  end

  test "should get index" do
    get donations_url
    assert_response :success
  end

  test "should get new" do
    get new_donation_url
    assert_response :success
  end

  test "should create donation" do
    assert_difference('Donation.count') do
      post donations_url, params: { donation: { lobbyist_id: @donation.lobbyist_id, representative_id: @donation.representative_id, value: @donation.value } }
    end

    assert_redirected_to donation_url(Donation.last)
  end

  test "should show donation" do
    get donation_url(@donation)
    assert_response :success
  end

  test "should get edit" do
    get edit_donation_url(@donation)
    assert_response :success
  end

  test "should update donation" do
    patch donation_url(@donation), params: { donation: { lobbyist_id: @donation.lobbyist_id, representative_id: @donation.representative_id, value: @donation.value } }
    assert_redirected_to donation_url(@donation)
  end

  test "should destroy donation" do
    assert_difference('Donation.count', -1) do
      delete donation_url(@donation)
    end

    assert_redirected_to donations_url
  end
end
