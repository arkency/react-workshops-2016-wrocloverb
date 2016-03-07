require 'test_helper'

class ApplicationAPITestSet < ActionDispatch::IntegrationTest
  protected
  ALL_EXPECTED_FORMATS = %w(html xml json jsonp)
  ACCEPTED_GET_FORMATS = %w(html jsonapi)
  ACCEPTED_POST_FORMATS = %w(jsonapi)

  def api_client
    @api_client ||= TestAPIClient.new(self) do |client|
      client.learn_root_urls!
    end
  end

  def assert_get_formats(url)
    ACCEPTED_GET_FORMATS.each do |accepted_format|
      api_client.raw_get url, format: accepted_format
      assert_response :ok
    end

    (ALL_EXPECTED_FORMATS - ACCEPTED_GET_FORMATS).each do |bad_format|
      api_client.raw_get url, format: bad_format
      assert_response :bad_request
    end
  end

  def assert_post_formats(url, params={})
    ACCEPTED_GET_FORMATS.each do |accepted_format|
      api_client.raw_post url, params.merge(format: accepted_format)
      assert_response :created
    end

    (ALL_EXPECTED_FORMATS - ACCEPTED_POST_FORMATS).each do |bad_format|
      api_client.raw_post url, params.merge(format: bad_format)
      assert_response :bad_request
    end
  end
end