require 'test_helper'

module ExpectedInitialFlowResponses
  def expected_root_url_response
    json({
      jsonapi: {
        version: "1.0"
      },
      links: {
        conferences: conferences_url
      }
    })
  end
end

class InitialFlowTest < ApplicationAPITestSet
  include ExpectedInitialFlowResponses

  def test_retrieving_paths_through_root_path
    api_client.assert_get_response(:"root",
      expected_root_url_response)
  end

  def test_accepted_formats
    assert_get_formats("/")
  end
end
