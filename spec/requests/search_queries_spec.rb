require 'rails_helper'

RSpec.describe SearchQueriesController, type: :controller do
  render_views

  describe 'POST #create' do
    let(:valid_attributes) do
      {
        query: 'new query'
      }
    end

    it 'creates a new SearchQuery' do
      expect {
        post :create, params: { query: valid_attributes[:query] }
      }.to change(SearchQuery, :count).by(1)
    end

    it 'saves the new SearchQuery in the database' do
      post :create, params: { query: valid_attributes[:query] }
      expect(SearchQuery.last.query).to eq(valid_attributes[:query])
    end
  end
  describe '#valid_complete_query?' do
  it 'returns true for valid queries' do
    expect(controller.send(:valid_complete_query?, 'hello')).to be true
  end

  it 'returns false for queries that are too short' do
    expect(controller.send(:valid_complete_query?, 'hi')).to be false
  end

  it 'returns false for nil queries' do
    expect(controller.send(:valid_complete_query?, nil)).to be false
  end
end

describe '#create_new_search_query' do
  it 'creates a new search query for valid, unique queries' do
    controller.send(:create_new_search_query, 'hello world', '127.0.0.1')
    expect(SearchQuery.find_by(query: 'hello world')).not_to be_nil
  end

  it 'does not create a new search query for queries that are a substring of a previous query' do
    SearchQuery.create(query: 'hello world', user_ip: '127.0.0.1')
    controller.send(:create_new_search_query, 'hello', '127.0.0.1')
    expect(SearchQuery.find_by(query: 'hello')).to be_nil
  end

  it 'does not create a new search query for queries that already exist' do
    SearchQuery.create(query: 'hello world', user_ip: '127.0.0.1')
    expect { controller.send(:create_new_search_query, 'hello world', '127.0.0.1') }.not_to change(SearchQuery, :count)
  end
end

describe 'GET #get_similar_queries' do
  before do
    allow_any_instance_of(ActionController::TestRequest).to receive(:remote_ip).and_return('127.0.0.1')
    SearchQuery.create(query: 'hello world', user_ip: '127.0.0.1')
    SearchQuery.create(query: 'hello', user_ip: '127.0.0.1')
    SearchQuery.create(query: 'world', user_ip: '127.0.0.1')
  end

  it 'returns similar queries for "hello"' do
    get :get_similar_queries, params: { query: 'hello' }
    expect(response.body).to include('hello world', 'hello')
  end

  it 'returns similar queries for "world"' do
    get :get_similar_queries, params: { query: 'world' }
    expect(response.body).to include('hello world', 'world')
  end

  it 'returns similar queries for "hello world"' do
    get :get_similar_queries, params: { query: 'hello world' }
    expect(response.body).to include('hello world')
  end

  before do
    allow_any_instance_of(ActionController::TestRequest).to receive(:remote_ip).and_return('127.0.0.1')
    SearchQuery.create(query: 'How is', user_ip: '127.0.0.1')
    SearchQuery.create(query: 'Howis emil hajric', user_ip: '127.0.0.1')
    SearchQuery.create(query: 'How is emil hajric doing', user_ip: '127.0.0.1')
  end

  it 'returns similar queries for "How is"' do
    get :get_similar_queries, params: { query: 'How is' }
    expect(response.body).to include('How is', 'How is emil hajric doing')
  end

  it 'returns similar queries for "Howis emil hajric"' do
    get :get_similar_queries, params: { query: 'Howis emil hajric' }
    expect(response.body).to include('Howis emil hajric')
  end

  it 'returns similar queries for "How is emil hajric doing"' do
    get :get_similar_queries, params: { query: 'How is emil hajric doing' }
    expect(response.body).to include('How is emil hajric doing', 'How is')
  end

  before do
    allow_any_instance_of(ActionController::TestRequest).to receive(:remote_ip).and_return('127.0.0.1')
    SearchQuery.create(query: 'What is', user_ip: '127.0.0.1')
    SearchQuery.create(query: 'What is a', user_ip: '127.0.0.1')
    SearchQuery.create(query: 'What is a good car', user_ip: '127.0.0.1')
  end

  it 'returns similar queries for "What is"' do
    get :get_similar_queries, params: { query: 'What is' }
    expect(response.body).to include('What is', 'What is a', 'What is a good car')
  end

  it 'returns similar queries for "What is a"' do
    get :get_similar_queries, params: { query: 'What is a' }
    expect(response.body).to include('What is a', 'What is a good car')
  end

  it 'returns similar queries for "What is a good car"' do
    get :get_similar_queries, params: { query: 'What is a good car' }
    expect(response.body).to include('What is a good car')
  end


  before do
    allow_any_instance_of(ActionController::TestRequest).to receive(:remote_ip).and_return('127.0.0.1')
    SearchQuery.create(query: 'hello', user_ip: '127.0.0.1')
    SearchQuery.create(query: 'Hello world', user_ip: '127.0.0.1')
    SearchQuery.create(query: 'Hello world how are you?', user_ip: '127.0.0.1')
  end

  it 'returns similar queries for "hello"' do
    get :get_similar_queries, params: { query: 'hello' }
    expect(response.body).to include('hello', 'Hello world', 'Hello world how are you?')
  end

  it 'returns similar queries for "Hello world"' do
    get :get_similar_queries, params: { query: 'Hello world' }
    expect(response.body).to include('Hello world', 'Hello world how are you?')
  end

  it 'returns similar queries for "Hello world how are you?"' do
    get :get_similar_queries, params: { query: 'Hello world how are you?' }
    expect(response.body).to include('Hello world how are you?')
  end

  before do
    allow_any_instance_of(ActionController::TestRequest).to receive(:remote_ip).and_return('127.0.0.1')
    SearchQuery.create(query: '123 hello', user_ip: '127.0.0.1')
    SearchQuery.create(query: 'hello 456', user_ip: '127.0.0.1')
    SearchQuery.create(query: 'hello@world', user_ip: '127.0.0.1')
  end
  
  it 'returns similar queries for "123 hello"' do
    get :get_similar_queries, params: { query: '123 hello' }
    expect(response.body).to include('123 hello')
  end
  
  it 'returns similar queries for "hello 456"' do
    get :get_similar_queries, params: { query: 'hello 456' }
    expect(response.body).to include('hello 456')
  end
  
  it 'returns similar queries for "hello@world"' do
    get :get_similar_queries, params: { query: 'hello@world' }
    expect(response.body).to include('hello@world')
  end
end
describe '#get_similar_queries with no matches' do
  before do
    allow_any_instance_of(ActionController::TestRequest).to receive(:remote_ip).and_return('127.0.0.1')
    SearchQuery.create(query: 'hello', user_ip: '127.0.0.1')
    SearchQuery.create(query: 'Hello world', user_ip: '127.0.0.1')
    SearchQuery.create(query: 'Hello world how are you?', user_ip: '127.0.0.1')
  end

  it 'returns no similar queries for a non-matching query' do
    get :get_similar_queries, params: { query: 'non-matching query' }
    expect(response.body).not_to include('hello', 'Hello world', 'Hello world how are you?')
  end
end

describe '#clean_up_incomplete_queries' do
  before do
    SearchQuery.create(query: 'hello world', user_ip: '127.0.0.1')
    SearchQuery.create(query: 'goodbye world', user_ip: '127.0.0.1')
    SearchQuery.create(query: 'goodbye', user_ip: '127.0.0.1')
  end

  it 'deletes incomplete queries' do
    controller.send(:clean_up_incomplete_queries, '127.0.0.1')
    expect(SearchQuery.find_by(query:'hello world')).not_to be_nil
  end
end
end