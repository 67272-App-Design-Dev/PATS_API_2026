require 'test_helper'

class Api::V1::OwnersControllerUpdateTest < ActionDispatch::IntegrationTest

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

  test "returns 200 with valid params" do
    patch "/v1/owners/#{@alex.id}", params: { city: "Pittsburgh" }, headers: @auth_headers
    assert_response :success
  end

  test "actually changes the value" do
    patch "/v1/owners/#{@alex.id}", params: { city: "Pittsburgh" }, headers: @auth_headers
    assert_equal "Pittsburgh", @alex.reload.city
  end

  test "returns 422 with invalid state" do
    patch "/v1/owners/#{@alex.id}", params: { state: "NY" }, headers: @auth_headers
    assert_response :unprocessable_entity
  end

  test "returns 404 for nonexistent owner" do
    patch "/v1/owners/0", params: { city: "Pittsburgh" }, headers: @auth_headers
    assert_response :not_found
  end

  test "returns 401 without token" do
    patch "/v1/owners/#{@alex.id}", params: { city: "Pittsburgh" }
    assert_response :unauthorized
  end

end
