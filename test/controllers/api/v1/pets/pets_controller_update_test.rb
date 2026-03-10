require 'test_helper'

class Api::V1::PetsControllerUpdateTest < ActionDispatch::IntegrationTest

  def setup
    create_animals
    create_owners
    create_pets
    @vet = FactoryBot.create(:user, first_name: "Jordan", last_name: "Stapinski", username: "jordan", role: "vet")
    @auth_headers = { "Authorization" => "Token token=#{@vet.api_key}" }
  end

  def teardown
    Pet.delete_all
    destroy_owners
    destroy_owner_users
    destroy_animals
    @vet.delete
  end

  test "returns 200 with valid params" do
    patch "/v1/pets/#{@dusty.id}", params: { name: "Dusty Jr." }, headers: @auth_headers
    assert_response :success
  end

  test "actually changes the value" do
    patch "/v1/pets/#{@dusty.id}", params: { name: "Dusty Jr." }, headers: @auth_headers
    assert_equal "Dusty Jr.", @dusty.reload.name
  end

  test "returns 422 with blank name" do
    patch "/v1/pets/#{@dusty.id}", params: { name: "" }, headers: @auth_headers
    assert_response :unprocessable_entity
  end

  test "returns 404 for nonexistent pet" do
    patch "/v1/pets/0", params: { name: "Ghost" }, headers: @auth_headers
    assert_response :not_found
  end

  test "returns 401 without token" do
    patch "/v1/pets/#{@dusty.id}", params: { name: "Dusty Jr." }
    assert_response :unauthorized
  end

end
