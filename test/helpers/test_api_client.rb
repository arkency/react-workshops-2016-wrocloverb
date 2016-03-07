class TestAPIClient
  def initialize(test_environment)
    @test_env = test_environment
    @kv_store = {}

    set!(:"root", @test_env.root_url)
  end

  def jsonapi_get(path, params={})
    test_env.get path, params.merge(format: :jsonapi)
    yield MultiJson.load(test_env.response.body)
  end

  def jsonapi_post(path, params={})
    test_env.post path, params.merge(format: :jsonapi)
    if test_env.response.status >= 300
      yield MultiJson.load(test_env.response.body)
    else
      yield test_env.response.status
    end
  end

  def next_uuid
    SecureRandom.uuid
  end

  def raw_get(path, params={})
    test_env.get path, params
    yield test_env.response if block_given?
  end

  def raw_post(path, params)
    test_env.post path, params
    yield test_env.response if block_given?
  end

  def learn_root_urls!
    jsonapi_get "/" do |response|
      response["links"].each do |name, url|
        set!("root/#{name}".to_sym, url)
      end
    end   
  end

  def learn_simple_links!(response_data)
    if response_data.is_a?(Array)
      response_data.each { |data| learn_simple_links!(data) }
    else
      id = response_data["id"] || response_data.fetch("data", {})["id"]
      type = response_data["type"] || response_data.fetch("data", {})["type"]
      raise StandardError.new("Could not figure out type of resource") if type.nil?
      response_data["links"].each do |key, value|
        set!("#{type}:#{id}/#{key}".to_sym, value)
      end
    end
  end

  def assert_get_response(key, expected, status = :ok)
    jsonapi_get(get(key)) do |response|
      test_env.assert_response status
      test_env.assert_equal expected, response
    end
  end

  def assert_post_error_response(key, params, expected, status = :unprocessable_entity)
    jsonapi_post(get(key), params) do |response|
      test_env.assert_response status
      test_env.assert_equal expected, response
    end
  end

  def discover_index_links!(key)
    jsonapi_get(get(key)) do |response|
      learn_simple_links!(response["data"])
    end
  end

  def discover_show_links!(key)
    jsonapi_get(get(key)) do |response|
      learn_simple_links!(response)
    end
  end

  def create(key, params)
    jsonapi_post(get(key), params) do |error|
      raise StandardError.new("Unexpected error while creating: " + error["errors"]["message"]) if test_env.response.status > 300
      test_env.assert_response :created
    end
  end

  def [](key)
    get(key)
  end

  def set!(key, value)
    @kv_store[key] = value
  end

  private
  attr_reader :test_env

  def get(key)
    @kv_store.fetch(key)
  end
end
