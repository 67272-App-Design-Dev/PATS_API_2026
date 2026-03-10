require 'test_helper'

class Api::V1::OwnersControllerIndexTest < ActionDispatch::IntegrationTest

  def setup
    create_owners
    @vet = FactoryBot.create(:user, first_name: "Jordan", last_name: "Stapinski", username: "jordan", role: "vet")
    @auth_headers = { "Authorization" => "Token token=#{@vet.api_key}" }
  end

  def teardown
    destroy_owners
    destroy_owner_users
    @vet.delete
  end

  test "returns 200 with valid token" do
    get "/v1/owners", headers: @auth_headers
    assert_response :success
  end

  test "returns 401 without token" do
    get "/v1/owners"
    assert_response :unauthorized
  end

  test "returns all owners" do
    get "/v1/owners", headers: @auth_headers
    result = JSON.parse(response.body)
    assert_equal 3, result["data"].count
  end

  test "returns only active owners when active=true" do
    get "/v1/owners", params: { active: true }, headers: @auth_headers
    result = JSON.parse(response.body)
    assert_equal 2, result["data"].count
  end

  test "returns only inactive owners when active=false" do
    get "/v1/owners", params: { active: false }, headers: @auth_headers
    result = JSON.parse(response.body)
    assert_equal 1, result["data"].count
  end

  test "returns owners in alphabetical order" do
    get "/v1/owners", params: { alphabetical: true }, headers: @auth_headers
    result = JSON.parse(response.body)
    names = result["data"].map { |o| o["attributes"]["name"] }
    assert_equal names, names.sort
  end

end
