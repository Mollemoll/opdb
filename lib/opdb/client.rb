# frozen_string_literal: true

require "faraday"
require "faraday_middleware"
require "opdb/http_status_codes"
require "opdb/api_exceptions"

module Opdb
  # Client wrapping the Open Pinball Database API
  class Client # rubocop:disable Metrics/ClassLength
    include ApiExceptions
    include HttpStatusCodes

    API_BASE_URI = "https://opdb.org/api"

    attr_reader :api_token

    def initialize(api_token: nil)
      @api_token = api_token
    end

    # Public Requests
    def changelog
      request(
        http_method: :get,
        endpoint: "changelog"
      )
    end

    def typeahead_search(q:, include_groups: "0", include_aliases: "1") # rubocop:disable Naming/MethodParameterName
      request(
        http_method: :get,
        endpoint: "search/typeahead",
        params: {
          q: q,
          include_groups: include_groups,
          include_aliases: include_aliases
        }
      )
    end

    # Requests that require a valid api_token
    def search_machines(q:, require_opdb: "1", include_groups: "0", include_aliases: "1", include_grouping_entries: "0") # rubocop:disable Naming/MethodParameterName, Metrics/MethodLength
      private_request(
        http_method: :get,
        endpoint: "search",
        params: {
          q: q,
          require_opdb: require_opdb,
          include_groups: include_groups,
          include_aliases: include_aliases,
          include_grouping_entries: include_grouping_entries
        }
      )
    end

    def get_machine_info(opdb_id:)
      private_request(
        http_method: :get,
        endpoint: "machines/#{opdb_id}"
      )
    end

    def get_machine_info_by_ipdb_id(ipdb_id:)
      private_request(
        http_method: :get,
        endpoint: "machines/ipdb/#{ipdb_id}"
      )
    end

    def export_machines
      private_request(
        http_method: :get,
        endpoint: "export"
      )
    end

    def export_machine_groups
      private_request(
        http_method: :get,
        endpoint: "export/groups"
      )
    end

    private

    def client
      @client ||= Faraday.new(API_BASE_URI) do |client|
        client.response :json
        client.headers["Accept"] = "application/json"
        client.headers["User-Agent"] = "opdb ruby client #{Opdb::VERSION}"
      end
    end

    def request(http_method:, endpoint:, params: {})
      response = client.public_send(http_method, endpoint, params)

      return response.body if response.status == HTTP_OK_CODE

      raise error_class(response.status), response.body.to_json
    end

    def private_request(http_method:, endpoint:, params: {})
      raise "Api key not set" unless @api_token

      params.merge!(
        { api_token: api_token }
      )
      request(
        http_method: http_method,
        endpoint: endpoint,
        params: params
      )
    end

    def error_class(response_status) # rubocop:disable Metrics/MethodLength
      case response_status
      when HTTP_BAD_REQUEST_CODE
        BadRequestError
      when HTTP_UNAUTHORIZED_CODE
        UnauthorizedError
      when HTTP_FORBIDDEN_CODE
        ForbiddenError
      when HTTP_NOT_FOUND_CODE
        NotFoundError
      when HTTP_UNPROCESSABLE_ENTITY_CODE
        UnprocessableEntityError
      else
        ApiError
      end
    end
  end
end
