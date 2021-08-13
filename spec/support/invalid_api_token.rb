# frozen_string_literal: true

require "pry"

RSpec.shared_examples "invalid api-token" do |method_call, params|
  let(:response_body) { { message: "Unauthenticated." }.to_json }
  let(:base_uri) { "https://opdb.org/api" }

  context "with an invalid api-token" do
    it "raises 401 Unauthenticated" do
      stub = stub_request(:get, /#{base_uri}.*/)
             .with(headers: headers)
             .to_return(status: 401, body: response_body)

      # binding.pry

      expect do
        if params
          described_class.new(api_token: "invalid").public_send(method_call, **params)
        else
          described_class.new(api_token: "invalid").public_send(method_call)
        end
        # expect { described_class.new(api_token: "invalid").public_send(method_call, **params)
        # expect { described_class.new(api_token: "invalid").eval("#{method_call}")}
      end.to(
        raise_error do |error|
          expect(error).to be_a ApiExceptions::UnauthorizedError
          expect(error.message).to eq response_body
        end
      )

      expect(stub).to have_been_requested
    end
  end
end
