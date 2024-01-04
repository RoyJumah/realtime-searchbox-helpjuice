class SearchQueriesController < ApplicationController
  skip_before_action :verify_authenticity_token

  def create
    query = params[:query]
    user_ip = session.id
    clean_up_incomplete_queries(user_ip)
    latest_complete_query = SearchQuery.where(user_ip: user_ip).where.not(query: nil).order(created_at: :desc).first
    if latest_complete_query.present? && query.length > latest_complete_query.query.length
      latest_complete_query.update(query: query)
    else
      create_new_search_query(query, user_ip)
    end
  end
  
  def get_similar_queries
    user_ip = session.id
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
    return unless valid_complete_query?(query)
    query_downcase = query.downcase.gsub(' ', '')
    previous_queries = SearchQuery.where(user_ip: user_ip)
    if previous_queries.any? { |previous_query| previous_query.query.downcase.gsub(' ', '').include?(query_downcase) }
      return
    end
    unless SearchQuery.exists?(query: query)
      @search_query = SearchQuery.new(query: query, user_ip: user_ip)
      @search_query.save
    end
  end

  def clean_up_incomplete_queries(user_ip)
    queries = SearchQuery.where(user_ip: user_ip).to_a
    queries.each do |query|
      is_prefix = queries.any? do |other_query|
        other_query != query && other_query.query.start_with?(query.query)
      end
      query.delete if is_prefix
    end
  end
end