require 'test_helper'

class Api::V1::OwnersControllerTest < ActionDispatch::IntegrationTest

  def setup
    create_owners  # internally calls create_owner_users
    @vet = FactoryBot.create(:user, first_name: "Jordan", last_name: "Stapinski", username: "jordan", role: "vet")
    @auth_headers = { "Authorization" => "Token token=#{@vet.api_key}" }
  end

  def teardown
    destroy_owners
    destroy_owner_users
    @vet.delete
  end

  # ===== INDEX =====

  test "index returns 200 with valid token" do
    get "/v1/owners", headers: @auth_headers
    assert_response :success
  end

  test "index returns 401 without token" do
    get "/v1/owners"
    assert_response :unauthorized
  end

  test "index returns all owners" do
    get "/v1/owners", headers: @auth_headers
    result = JSON.parse(response.body)
    assert_equal 3, result["data"].count
  end

  test "index returns only active owners when active=true" do
    get "/v1/owners", params: { active: true }, headers: @auth_headers
    result = JSON.parse(response.body)
    assert_equal 2, result["data"].count
  end

  test "index returns only inactive owners when active=false" do
    get "/v1/owners", params: { active: false }, headers: @auth_headers
    result = JSON.parse(response.body)
    assert_equal 1, result["data"].count
  end

  test "index returns owners in alphabetical order" do
    get "/v1/owners", params: { alphabetical: true }, headers: @auth_headers
    result = JSON.parse(response.body)
    names = result["data"].map { |o| o["attributes"]["name"] }
    assert_equal names, names.sort
  end

  # ===== SHOW =====

  test "show returns 200 for valid owner" do
    get "/v1/owners/#{@alex.id}", headers: @auth_headers
    assert_response :success
  end

  test "show returns 404 for nonexistent owner" do
    get "/v1/owners/0", headers: @auth_headers
    assert_response :not_found
  end

  test "show returns correct JSON attributes" do
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

  test "show returns correct owner name" do
    get "/v1/owners/#{@alex.id}", headers: @auth_headers
    result = JSON.parse(response.body)
    assert_equal "Heimann, Alex", result["data"]["attributes"]["name"]
  end

  # ===== CREATE =====

  test "create with valid params increases owner count" do
    assert_difference("Owner.count", 1) do
      post "/v1/owners", params: {
        first_name: "New", last_name: "Owner",
        phone: "4125551234", email: "new.owner@example.com",
        state: "PA", zip: "15201",
        username: "newowner", password: "secret", password_confirmation: "secret"
      }, headers: @auth_headers
    end
    assert_response :success
  end

  test "create also creates an associated user" do
    assert_difference("User.count", 1) do
      post "/v1/owners", params: {
        first_name: "New", last_name: "Owner",
        phone: "4125551234", email: "new.owner@example.com",
        state: "PA", zip: "15201",
        username: "newowner2", password: "secret", password_confirmation: "secret"
      }, headers: @auth_headers
    end
  end

  test "create returns 422 with missing last name" do
    post "/v1/owners", params: {
      first_name: "Incomplete",
      username: "incomplete", password: "secret", password_confirmation: "secret"
    }, headers: @auth_headers
    assert_response :unprocessable_entity
  end

  test "create returns 422 with invalid state" do
    post "/v1/owners", params: {
      first_name: "New", last_name: "Owner",
      phone: "4125551234", email: "new.owner@example.com",
      state: "NY", zip: "15201",
      username: "newowner3", password: "secret", password_confirmation: "secret"
    }, headers: @auth_headers
    assert_response :unprocessable_entity
  end

  test "create returns 401 without token" do
    post "/v1/owners", params: {
      first_name: "New", last_name: "Owner",
      phone: "4125551234", email: "new.owner@example.com",
      state: "PA", username: "newowner4", password: "secret", password_confirmation: "secret"
    }
    assert_response :unauthorized
  end

  # ===== UPDATE =====

  test "update returns 200 with valid params" do
    patch "/v1/owners/#{@alex.id}", params: { city: "Pittsburgh" }, headers: @auth_headers
    assert_response :success
  end

  test "update actually changes the value" do
    patch "/v1/owners/#{@alex.id}", params: { city: "Pittsburgh" }, headers: @auth_headers
    assert_equal "Pittsburgh", @alex.reload.city
  end

  test "update returns 422 with invalid state" do
    patch "/v1/owners/#{@alex.id}", params: { state: "NY" }, headers: @auth_headers
    assert_response :unprocessable_entity
  end

  test "update returns 404 for nonexistent owner" do
    patch "/v1/owners/0", params: { city: "Pittsburgh" }, headers: @auth_headers
    assert_response :not_found
  end

  test "update returns 401 without token" do
    patch "/v1/owners/#{@alex.id}", params: { city: "Pittsburgh" }
    assert_response :unauthorized
  end

  # ===== DESTROY =====

  test "destroy decrements owner count" do
    assert_difference("Owner.count", -1) do
      delete "/v1/owners/#{@mark.id}", headers: @auth_headers
    end
  end

  test "destroy returns 404 for nonexistent owner" do
    delete "/v1/owners/0", headers: @auth_headers
    assert_response :not_found
  end

  test "destroy returns 401 without token" do
    delete "/v1/owners/#{@alex.id}"
    assert_response :unauthorized
  end

end
