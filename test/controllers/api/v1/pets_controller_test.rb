require 'test_helper'

class Api::V1::PetsControllerTest < ActionDispatch::IntegrationTest

  def setup
    create_animals   # sets @cat, @dog, @turtle (inactive), etc.
    create_owners    # internally calls create_owner_users; sets @alex, @rachel (inactive), @mark
    create_pets      # sets @dusty (male, cat, alex), @polo (female, cat, alex, inactive), @pork_chop (female, dog, mark)
    @vet = FactoryBot.create(:user, first_name: "Jordan", last_name: "Stapinski", username: "jordan", role: "vet")
    @auth_headers = { "Authorization" => "Token token=#{@vet.api_key}" }
  end

  def teardown
    Pet.delete_all   # catches any extra pets created during tests (e.g., in create tests)
    destroy_owners
    destroy_owner_users
    destroy_animals
    @vet.delete
  end

  # ===== INDEX =====

  test "index returns 200 with valid token" do
    get "/v1/pets", headers: @auth_headers
    assert_response :success
  end

  test "index returns 401 without token" do
    get "/v1/pets"
    assert_response :unauthorized
  end

  test "index returns all pets" do
    get "/v1/pets", headers: @auth_headers
    result = JSON.parse(response.body)
    assert_equal 3, result["data"].count
  end

  test "index returns only active pets when active=true" do
    get "/v1/pets", params: { active: true }, headers: @auth_headers
    result = JSON.parse(response.body)
    assert_equal 2, result["data"].count
  end

  test "index returns only inactive pets when active=false" do
    get "/v1/pets", params: { active: false }, headers: @auth_headers
    result = JSON.parse(response.body)
    assert_equal 1, result["data"].count
  end

  test "index returns only female pets when females=true" do
    get "/v1/pets", params: { females: true }, headers: @auth_headers
    result = JSON.parse(response.body)
    # @polo and @pork_chop are female (factory default: female: true); @dusty is male
    assert_equal 2, result["data"].count
  end

  test "index filters pets by owner" do
    get "/v1/pets", params: { for_owner: @alex.id }, headers: @auth_headers
    result = JSON.parse(response.body)
    # @alex owns @dusty and @polo
    assert_equal 2, result["data"].count
  end

  test "index filters pets by animal type" do
    get "/v1/pets", params: { by_animal: @cat.id }, headers: @auth_headers
    result = JSON.parse(response.body)
    # @dusty and @polo are cats
    assert_equal 2, result["data"].count
  end

  test "index returns pets in alphabetical order" do
    get "/v1/pets", params: { alphabetical: true }, headers: @auth_headers
    result = JSON.parse(response.body)
    names = result["data"].map { |p| p["attributes"]["name"] }
    assert_equal names, names.sort
  end

  # ===== SHOW =====

  test "show returns 200 for valid pet" do
    get "/v1/pets/#{@dusty.id}", headers: @auth_headers
    assert_response :success
  end

  test "show returns 404 for nonexistent pet" do
    get "/v1/pets/0", headers: @auth_headers
    assert_response :not_found
  end

  test "show returns correct JSON attributes" do
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

  test "show returns gender as lowercase string" do
    get "/v1/pets/#{@dusty.id}", headers: @auth_headers
    result = JSON.parse(response.body)
    assert_equal "male", result["data"]["attributes"]["gender"]
  end

  test "show returns animal as lowercase string" do
    get "/v1/pets/#{@dusty.id}", headers: @auth_headers
    result = JSON.parse(response.body)
    assert_equal "cat", result["data"]["attributes"]["animal"]
  end

  test "show returns correct pet name" do
    get "/v1/pets/#{@dusty.id}", headers: @auth_headers
    result = JSON.parse(response.body)
    assert_equal "Dusty", result["data"]["attributes"]["name"]
  end

  # ===== CREATE =====

  test "create with valid params increases pet count" do
    assert_difference("Pet.count", 1) do
      post "/v1/pets", params: {
        name: "Fluffy", animal_id: @cat.id, owner_id: @alex.id,
        female: true, date_of_birth: 5.years.ago.to_date
      }, headers: @auth_headers
    end
    assert_response :success
  end

  test "create returns 422 with missing name" do
    post "/v1/pets", params: {
      animal_id: @cat.id, owner_id: @alex.id
    }, headers: @auth_headers
    assert_response :unprocessable_entity
  end

  test "create returns 422 with inactive owner" do
    post "/v1/pets", params: {
      name: "Fluffy", animal_id: @cat.id, owner_id: @rachel.id
    }, headers: @auth_headers
    assert_response :unprocessable_entity
  end

  test "create returns 422 with inactive animal" do
    post "/v1/pets", params: {
      name: "Fluffy", animal_id: @turtle.id, owner_id: @alex.id
    }, headers: @auth_headers
    assert_response :unprocessable_entity
  end

  test "create returns 401 without token" do
    post "/v1/pets", params: {
      name: "Fluffy", animal_id: @cat.id, owner_id: @alex.id
    }
    assert_response :unauthorized
  end

  # ===== UPDATE =====

  test "update returns 200 with valid params" do
    patch "/v1/pets/#{@dusty.id}", params: { name: "Dusty Jr." }, headers: @auth_headers
    assert_response :success
  end

  test "update actually changes the value" do
    patch "/v1/pets/#{@dusty.id}", params: { name: "Dusty Jr." }, headers: @auth_headers
    assert_equal "Dusty Jr.", @dusty.reload.name
  end

  test "update returns 422 with blank name" do
    patch "/v1/pets/#{@dusty.id}", params: { name: "" }, headers: @auth_headers
    assert_response :unprocessable_entity
  end

  test "update returns 404 for nonexistent pet" do
    patch "/v1/pets/0", params: { name: "Ghost" }, headers: @auth_headers
    assert_response :not_found
  end

  test "update returns 401 without token" do
    patch "/v1/pets/#{@dusty.id}", params: { name: "Dusty Jr." }
    assert_response :unauthorized
  end

  # ===== DESTROY =====

  test "destroy decrements pet count" do
    assert_difference("Pet.count", -1) do
      delete "/v1/pets/#{@polo.id}", headers: @auth_headers
    end
  end

  test "destroy returns 404 for nonexistent pet" do
    delete "/v1/pets/0", headers: @auth_headers
    assert_response :not_found
  end

  test "destroy returns 401 without token" do
    delete "/v1/pets/#{@dusty.id}"
    assert_response :unauthorized
  end

end
