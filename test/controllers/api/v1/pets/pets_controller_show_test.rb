require 'test_helper'

class Api::V1::PetsControllerShowTest < ActionDispatch::IntegrationTest

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

  test "returns 200 for valid pet" do
    get "/v1/pets/#{@dusty.id}", headers: @auth_headers
    assert_response :success
  end

  test "returns 404 for nonexistent pet" do
    get "/v1/pets/0", headers: @auth_headers
    assert_response :not_found
  end

  test "returns correct JSON attributes" do
    get "/v1/pets/#{@dusty.id}", headers: @auth_headers
    result = JSON.parse(response.body)
    attrs = result["data"]["attributes"]
    assert attrs.key?("name")
    assert attrs.key?("date_of_birth")
    assert attrs.key?("animal")
    assert attrs.key?("gender")
    assert attrs.key?("owner")
    assert attrs.key?("visits")
  end

  test "returns gender as lowercase string" do
    get "/v1/pets/#{@dusty.id}", headers: @auth_headers
    result = JSON.parse(response.body)
    assert_equal "male", result["data"]["attributes"]["gender"]
  end

  test "returns animal as lowercase string" do
    get "/v1/pets/#{@dusty.id}", headers: @auth_headers
    result = JSON.parse(response.body)
    assert_equal "cat", result["data"]["attributes"]["animal"]
  end

  test "returns correct pet name" do
    get "/v1/pets/#{@dusty.id}", headers: @auth_headers
    result = JSON.parse(response.body)
    assert_equal "Dusty", result["data"]["attributes"]["name"]
  end

end
