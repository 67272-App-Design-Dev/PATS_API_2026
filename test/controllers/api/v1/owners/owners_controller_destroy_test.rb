require 'test_helper'

class Api::V1::OwnersControllerDestroyTest < ActionDispatch::IntegrationTest

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

  test "decrements owner count" do
    assert_difference("Owner.count", -1) do
      delete "/v1/owners/#{@mark.id}", headers: @auth_headers
    end
  end

  test "returns 404 for nonexistent owner" do
    delete "/v1/owners/0", headers: @auth_headers
    assert_response :not_found
  end

  test "returns 401 without token" do
    delete "/v1/owners/#{@alex.id}"
    assert_response :unauthorized
  end

end
