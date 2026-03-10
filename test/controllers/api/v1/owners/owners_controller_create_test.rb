require 'test_helper'

class Api::V1::OwnersControllerCreateTest < ActionDispatch::IntegrationTest

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

  test "with valid params increases owner count" do
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

  test "also creates an associated user" do
    assert_difference("User.count", 1) do
      post "/v1/owners", params: {
        first_name: "New", last_name: "Owner",
        phone: "4125551234", email: "new.owner@example.com",
        state: "PA", zip: "15201",
        username: "newowner2", password: "secret", password_confirmation: "secret"
      }, headers: @auth_headers
    end
  end

  test "returns 422 with missing last name" do
    post "/v1/owners", params: {
      first_name: "Incomplete",
      username: "incomplete", password: "secret", password_confirmation: "secret"
    }, headers: @auth_headers
    assert_response :unprocessable_entity
  end

  test "returns 422 with invalid state" do
    post "/v1/owners", params: {
      first_name: "New", last_name: "Owner",
      phone: "4125551234", email: "new.owner@example.com",
      state: "NY", zip: "15201",
      username: "newowner3", password: "secret", password_confirmation: "secret"
    }, headers: @auth_headers
    assert_response :unprocessable_entity
  end

  test "returns 401 without token" do
    post "/v1/owners", params: {
      first_name: "New", last_name: "Owner",
      phone: "4125551234", email: "new.owner@example.com",
      state: "PA", username: "newowner4", password: "secret", password_confirmation: "secret"
    }
    assert_response :unauthorized
  end

end
