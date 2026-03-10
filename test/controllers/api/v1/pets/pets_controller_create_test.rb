require 'test_helper'

class Api::V1::PetsControllerCreateTest < ActionDispatch::IntegrationTest

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

  test "with valid params increases pet count" do
    assert_difference("Pet.count", 1) do
      post "/v1/pets", params: {
        name: "Fluffy", animal_id: @cat.id, owner_id: @alex.id,
        female: true, date_of_birth: 5.years.ago.to_date
      }, headers: @auth_headers
    end
    assert_response :success
  end

  test "returns 422 with missing name" do
    post "/v1/pets", params: {
      animal_id: @cat.id, owner_id: @alex.id
    }, headers: @auth_headers
    assert_response :unprocessable_entity
  end

  test "returns 422 with inactive owner" do
    post "/v1/pets", params: {
      name: "Fluffy", animal_id: @cat.id, owner_id: @rachel.id
    }, headers: @auth_headers
    assert_response :unprocessable_entity
  end

  test "returns 422 with inactive animal" do
    post "/v1/pets", params: {
      name: "Fluffy", animal_id: @turtle.id, owner_id: @alex.id
    }, headers: @auth_headers
    assert_response :unprocessable_entity
  end

  test "returns 401 without token" do
    post "/v1/pets", params: {
      name: "Fluffy", animal_id: @cat.id, owner_id: @alex.id
    }
    assert_response :unauthorized
  end

end
