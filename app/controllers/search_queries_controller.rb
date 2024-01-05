class SearchQueriesController < ApplicationController
  skip_before_action :verify_authenticity_token

  def create
    query = params[:query]
    user_ip = request.headers['X-Forwarded-For'] || request.remote_ip
    # Clean up incomplete queries before creating a new one
    clean_up_incomplete_queries(user_ip)
    # Find the latest complete search query for the user
    latest_complete_query = SearchQuery.where(user_ip: user_ip).where.not(query: nil).order(created_at: :desc).first
    if latest_complete_query.present? && query.length > latest_complete_query.query.length
      # If the new query is longer, update the existing complete query
      latest_complete_query.update(query: query)
    else
      # If it's a new or shorter complete query, create a new record
      create_new_search_query(query, user_ip)
    end
  end
  
  def get_similar_queries
    user_ip = request.headers['X-Forwarded-For'] || request.remote_ip
    query = params[:query].to_s.strip.downcase.gsub(' ', '')
    similar_queries = SearchQuery
                    .where(user_ip: user_ip)
                    .where("REPLACE(LOWER(query), ' ', '') LIKE ?", "%#{query}%")
                    .pluck(:query)
    puts "Generated SQL Query: #{SearchQuery.where(user_ip: user_ip).where("REPLACE(LOWER(query), ' ', '') LIKE ?", "%#{query}%").to_sql}"
    render json: { similar_queries: similar_queries }
  end

  private

  def valid_complete_query?(query)
    query.present? && query.length >= 3
  end

  def create_new_search_query(query, user_ip)
    # Create a new search query only if it's a complete and valid query
    return unless valid_complete_query?(query)
    # Convert the new query to lowercase and remove spaces
    query_downcase = query.downcase.gsub(' ', '')
    # Check if the new query is a substring of any previous query
    previous_queries = SearchQuery.where(user_ip: user_ip)
    if previous_queries.any? { |previous_query| previous_query.query.downcase.gsub(' ', '').include?(query_downcase) }
      # If it is, don't save the new query
      return
    end
    # If it's a completely new query, create a new record
    # Only if it's not already in the database
    unless SearchQuery.exists?(query: query)
      @search_query = SearchQuery.new(query: query, user_ip: user_ip)
      @search_query.save
    end
  end

  def clean_up_incomplete_queries(user_ip)
    # Get all queries for the user
    queries = SearchQuery.where(user_ip: user_ip).to_a
  
    queries.each do |query|
      # For each query, check if it's a prefix of any other query
      is_prefix = queries.any? do |other_query|
        other_query != query && other_query.query.start_with?(query.query)
      end
  
      # If the query is a prefix of any other query, delete it
      query.delete if is_prefix
    end
  end
end