require 'test_helper'

class Api::V1::OwnersControllerShowTest < ActionDispatch::IntegrationTest

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

  test "returns 200 for valid owner" do
    get "/v1/owners/#{@alex.id}", headers: @auth_headers
    assert_response :success
  end

  test "returns 404 for nonexistent owner" do
    get "/v1/owners/0", headers: @auth_headers
    assert_response :not_found
  end

  test "returns correct JSON attributes" do
    get "/v1/owners/#{@alex.id}", headers: @auth_headers
    result = JSON.parse(response.body)
    attrs = result["data"]["attributes"]
    assert attrs.key?("name")
    assert attrs.key?("email")
    assert attrs.key?("phone")
    assert attrs.key?("street")
    assert attrs.key?("city")
    assert attrs.key?("state")
    assert attrs.key?("zip")
    assert attrs.key?("active_pets")
    assert attrs.key?("inactive_pets")
  end

  test "returns correct owner name" do
    get "/v1/owners/#{@alex.id}", headers: @auth_headers
    result = JSON.parse(response.body)
    assert_equal "Heimann, Alex", result["data"]["attributes"]["name"]
  end

end
