require 'test_helper'

class RepresenativesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @represenative = represenatives(:one)
  end

  test "should get index" do
    get represenatives_url
    assert_response :success
  end

  test "should get new" do
    get new_represenative_url
    assert_response :success
  end

  test "should create represenative" do
    assert_difference('Represenative.count') do
      post represenatives_url, params: { represenative: { beliefs: @represenative.beliefs, district: @represenative.district, email: @represenative.email, img: @represenative.img, name: @represenative.name, party: @represenative.party, rating: @represenative.rating, url: @represenative.url } }
    end

    assert_redirected_to represenative_url(Represenative.last)
  end

  test "should show represenative" do
    get represenative_url(@represenative)
    assert_response :success
  end

  test "should get edit" do
    get edit_represenative_url(@represenative)
    assert_response :success
  end

  test "should update represenative" do
    patch represenative_url(@represenative), params: { represenative: { beliefs: @represenative.beliefs, district: @represenative.district, email: @represenative.email, img: @represenative.img, name: @represenative.name, party: @represenative.party, rating: @represenative.rating, url: @represenative.url } }
    assert_redirected_to represenative_url(@represenative)
  end

  test "should destroy represenative" do
    assert_difference('Represenative.count', -1) do
      delete represenative_url(@represenative)
    end

    assert_redirected_to represenatives_url
  end
end
