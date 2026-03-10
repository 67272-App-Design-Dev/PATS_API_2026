require 'test_helper'

class Api::V1::PetsControllerIndexTest < ActionDispatch::IntegrationTest

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

  test "returns 200 with valid token" do
    get "/v1/pets", headers: @auth_headers
    assert_response :success
  end

  test "returns 401 without token" do
    get "/v1/pets"
    assert_response :unauthorized
  end

  test "returns all pets" do
    get "/v1/pets", headers: @auth_headers
    result = JSON.parse(response.body)
    assert_equal 3, result["data"].count
  end

  test "returns only active pets when active=true" do
    get "/v1/pets", params: { active: true }, headers: @auth_headers
    result = JSON.parse(response.body)
    assert_equal 2, result["data"].count
  end

  test "returns only inactive pets when active=false" do
    get "/v1/pets", params: { active: false }, headers: @auth_headers
    result = JSON.parse(response.body)
    assert_equal 1, result["data"].count
  end

  test "returns only female pets when females=true" do
    get "/v1/pets", params: { females: true }, headers: @auth_headers
    result = JSON.parse(response.body)
    assert_equal 2, result["data"].count
  end

  test "filters pets by owner" do
    get "/v1/pets", params: { for_owner: @alex.id }, headers: @auth_headers
    result = JSON.parse(response.body)
    assert_equal 2, result["data"].count
  end

  test "filters pets by animal type" do
    get "/v1/pets", params: { by_animal: @cat.id }, headers: @auth_headers
    result = JSON.parse(response.body)
    assert_equal 2, result["data"].count
  end

  test "returns pets in alphabetical order" do
    get "/v1/pets", params: { alphabetical: true }, headers: @auth_headers
    result = JSON.parse(response.body)
    names = result["data"].map { |p| p["attributes"]["name"] }
    assert_equal names, names.sort
  end

end
