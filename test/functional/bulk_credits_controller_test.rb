require 'test_helper'

class BulkCreditsControllerTest < ActionController::TestCase
  setup do
    @bulk_credit = bulk_credits(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:bulk_credits)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create bulk_credit" do
    assert_difference('BulkCredit.count') do
      post :create, bulk_credit: { amount: @bulk_credit.amount, name: @bulk_credit.name, unit: @bulk_credit.unit }
    end

    assert_redirected_to bulk_credit_path(assigns(:bulk_credit))
  end

  test "should show bulk_credit" do
    get :show, id: @bulk_credit
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @bulk_credit
    assert_response :success
  end

  test "should update bulk_credit" do
    put :update, id: @bulk_credit, bulk_credit: { amount: @bulk_credit.amount, name: @bulk_credit.name, unit: @bulk_credit.unit }
    assert_redirected_to bulk_credit_path(assigns(:bulk_credit))
  end

  test "should destroy bulk_credit" do
    assert_difference('BulkCredit.count', -1) do
      delete :destroy, id: @bulk_credit
    end

    assert_redirected_to bulk_credits_path
  end
end
