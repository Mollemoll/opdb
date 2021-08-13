# frozen_string_literal: true

RSpec.describe Opdb::Client do # rubocop:disable Metrics/BlockLength
  let(:api_base_uri) { "https://opdb.org/api" }
  let(:client) { Opdb::Client.new(api_token: "api_token") }
  let(:headers) { { "Accept" => "application/json" } }

  it "knows the API_BASE_URI" do
    expect(client.class::API_BASE_URI).to eq api_base_uri
  end

  # Public API
  context "public api endpoints" do # rubocop:disable Metrics/BlockLength
    describe "#typeahead_search" do
      let(:typeahead_search_uri) { "#{api_base_uri}/search/typeahead" }
      let(:typeahead_search_response) { File.read("spec/fixtures/typeahead_search_response.json") }

      it "get '/search/typeahead' and returns valid json" do
        stub = stub_request(:get, typeahead_search_uri)
               .with(query: {
                       q: "Metallica (PRO LED)",
                       include_groups: 0,
                       include_aliases: 1
                     }, headers: headers)
               .to_return(status: 200, body: typeahead_search_response.to_json)

        response = client.typeahead_search(q: "Metallica (PRO LED)")
        expect(stub).to have_been_requested
        expect(response).to eq typeahead_search_response
      end
    end

    describe "#changelog" do
      let(:changelog_uri) { "#{api_base_uri}/changelog" }

      it "get '/changelog' and returns valid json" do
        stub = stub_request(:get, changelog_uri)
               .with(headers: headers)
               .to_return(status: 200)

        client.changelog
        expect(stub).to have_been_requested
      end
    end
  end

  # API for authenticated clients
  context "api endpoints that requires authentication" do # rubocop:disable Metrics/BlockLength
    it "has an api-token" do
      expect(client.api_token).not_to be nil
    end

    describe "#search_machines" do
      include_examples("invalid api-token", "search_machines", q: "Metallica (PRO LED)")

      context "with a valid api-token" do
        let(:search_uri) { "#{api_base_uri}/search" }
        let(:response_metallica_game) { File.read("spec/fixtures/response_metallica_game.json") }

        it "get '/search' with metallica query and returns valid json" do
          stub = stub_request(:get, search_uri)
                 .with(query: {
                         q: "Metallica (PRO LED)",
                         require_opdb: 1,
                         include_groups: 0,
                         include_aliases: 1,
                         include_grouping_entries: 0,
                         api_token: client.api_token
                       })
                 .to_return(status: 200, body: response_metallica_game.to_json)

          response = client.search_machines(q: "Metallica (PRO LED)")
          expect(stub).to have_been_requested
          expect(response).to eq response_metallica_game
        end
      end
    end

    describe "#get_machine_info" do
      let(:get_machine_info_uri) { "#{api_base_uri}/machines" }
      let(:response_metallica_game) { File.read("spec/fixtures/response_metallica_game.json") }

      include_examples("invalid api-token", "get_machine_info", opdb_id: "GRBE4-MQK1Z-A9Yn1")

      context "with existing opdb id" do
        it "get '/machines/GRBE4-MQK1Z-A9Yn1' and returns valid json" do
          stub = stub_request(:get, "#{get_machine_info_uri}/GRBE4-MQK1Z-A9Yn1")
                 .with(query: { api_token: client.api_token })
                 .to_return(status: 200, body: response_metallica_game.to_json)

          response = client.get_machine_info(opdb_id: "GRBE4-MQK1Z-A9Yn1")
          expect(stub).to have_been_requested
          expect(response).to eq response_metallica_game
        end
      end

      context "with non existing opdb id" do
        it "raises 404 NotFoundError" do
          stub = stub_request(:get, "#{get_machine_info_uri}/wrong-id")
                 .with(query: { api_token: client.api_token })
                 .to_return(status: 404)

          expect { client.get_machine_info(opdb_id: "wrong-id") }
            .to raise_error ApiExceptions::NotFoundError
          expect(stub).to have_been_requested
        end
      end
    end

    describe "#get_machine_info_by_ipdb_id" do
      let(:get_machine_info_by_ipdb_id_uri) { "#{api_base_uri}/machines/ipdb" }
      let(:response_metallica_game) { File.read("spec/fixtures/response_metallica_game.json") }

      include_examples("invalid api-token", "get_machine_info_by_ipdb_id", ipdb_id: 6179)

      context "with existing ipdb id" do
        it "get '/machines/ipdb/6179' and returns valid json" do
          stub = stub_request(:get, "#{get_machine_info_by_ipdb_id_uri}/6179")
                 .with(query: { api_token: client.api_token })
                 .to_return(status: 200, body: response_metallica_game.to_json)

          response = client.get_machine_info_by_ipdb_id(ipdb_id: 6179)
          expect(stub).to have_been_requested
          expect(response).to eq response_metallica_game
        end
      end

      context "with non existing ipdb id" do
        it "raises 404 NotFoundError" do
          stub = stub_request(:get, "#{get_machine_info_by_ipdb_id_uri}/wrong-id")
                 .with(query: { api_token: client.api_token })
                 .to_return(status: 404)

          expect { client.get_machine_info_by_ipdb_id(ipdb_id: "wrong-id") }
            .to raise_error ApiExceptions::NotFoundError
          expect(stub).to have_been_requested
        end
      end
    end

    describe "#export_machines" do
      let(:export_machines_uri) { "#{api_base_uri}/export" }

      include_examples "invalid api-token", "export_machines"

      it "get '/export' and returns valid json" do
        stub = stub_request(:get, export_machines_uri)
               .with(query: { api_token: client.api_token })
               .to_return(status: 200)

        client.export_machines
        expect(stub).to have_been_requested
      end
    end

    describe "#export_machine_groups" do
      let(:export_machine_groups_uri) { "#{api_base_uri}/export/groups" }

      include_examples "invalid api-token", "export_machine_groups"

      it "get '/export/groups' and returns valid json" do
        stub = stub_request(:get, export_machine_groups_uri)
               .with(query: { api_token: client.api_token })
               .to_return(status: 200)

        client.export_machine_groups
        expect(stub).to have_been_requested
      end
    end
  end
end
