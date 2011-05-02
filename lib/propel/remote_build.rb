require 'rss'
require 'json'

require 'net/http'

module Propel
  class RemoteBuild
    def initialize(status_url)
      @status_url = status_url
    end

    FAIL_PATTERNS = {
        :jenkins    => /\(broken/,
        :team_city  => /(?:has failed)$/,
        :ci_joe     => /^failed$/
    }

    def passing?
      !!FAIL_PATTERNS.values.detect{|pattern| most_recent_results =~ pattern }.nil?
    end

    private
    def most_recent_results
      if contents = rss_contents
        contents.entries.first.title.content
      else
        json_contents["jobs"].first["status"]
      end
    end

    def rss_contents
      RSS::Parser.parse(retrieve_test_results, false)
    end

    def json_contents
      JSON.parse(retrieve_test_results)
    end

    def retrieve_test_results
      @_test_results ||= Net::HTTP.get URI.parse(@status_url)
    end
  end
end