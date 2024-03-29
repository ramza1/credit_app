require 'test_helper'

class AirtimesControllerTest < ActionController::TestCase
  setup do
    @credit = credits(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:airtimes)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create credit" do
    assert_difference('Airtime.count') do
      post :create, credit: { card_type: @credit.card_type, encrypted_pin: @credit.encrypted_pin, name: @credit.name, price: @credit.price, sold: @credit.sold, state: @credit.state }
    end

    assert_redirected_to credit_path(assigns(:credit))
  end

  test "should show credit" do
    get :show, id: @credit
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @credit
    assert_response :success
  end

  test "should update credit" do
    put :update, id: @credit, credit: { card_type: @credit.card_type, encrypted_pin: @credit.encrypted_pin, name: @credit.name, price: @credit.price, sold: @credit.sold, state: @credit.state }
    assert_redirected_to credit_path(assigns(:credit))
  end

  test "should destroy credit" do
    assert_difference('Airtime.count', -1) do
      delete :destroy, id: @credit
    end

    assert_redirected_to credits_path
  end
end
