require 'test_helper'

class Api::V1::PetsControllerDestroyTest < ActionDispatch::IntegrationTest

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

  test "decrements pet count" do
    assert_difference("Pet.count", -1) do
      delete "/v1/pets/#{@polo.id}", headers: @auth_headers
    end
  end

  test "returns 404 for nonexistent pet" do
    delete "/v1/pets/0", headers: @auth_headers
    assert_response :not_found
  end

  test "returns 401 without token" do
    delete "/v1/pets/#{@dusty.id}"
    assert_response :unauthorized
  end

end
