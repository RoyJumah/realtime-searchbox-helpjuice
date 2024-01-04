require "application_system_test_case"

class SearchQueriesTest < ApplicationSystemTestCase
  setup do
    @search_query = search_queries(:one)
  end

  test "visiting the index" do
    visit search_queries_url
    assert_selector "h1", text: "Search queries"
  end

  test "should create search query" do
    visit search_queries_url
    click_on "New search query"

    fill_in "Query", with: @search_query.query
    fill_in "User ip", with: @search_query.user_ip
    click_on "Create Search query"

    assert_text "Search query was successfully created"
    click_on "Back"
  end

  test "should update Search query" do
    visit search_query_url(@search_query)
    click_on "Edit this search query", match: :first

    fill_in "Query", with: @search_query.query
    fill_in "User ip", with: @search_query.user_ip
    click_on "Update Search query"

    assert_text "Search query was successfully updated"
    click_on "Back"
  end

  test "should destroy Search query" do
    visit search_query_url(@search_query)
    click_on "Destroy this search query", match: :first

    assert_text "Search query was successfully destroyed"
  end
end
