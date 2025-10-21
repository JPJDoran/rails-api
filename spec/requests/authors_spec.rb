require 'swagger_helper'

RSpec.describe 'authors', type: :request do
  path '/authors' do

    get 'List all authors' do
      tags 'Authors'
      produces 'application/json'
      description 'Returns a list of all authors in the system'
      security [{ ApiKeyAuth: [] }]  # references global API key
      parameter name: :X_Api_Key, in: :header, type: :string, required: true, description: 'API Key'
      response '200', 'authors found' do
        schema type: :array, items: {
          type: :object,
          properties: {
            id: { type: :integer, description: 'Unique ID of the author' },
            name: { type: :string, description: 'Author full name' }
          },
          required: %w[id name]
        }

        example 'application/json', :authorized_not_empty_example, [
          { id: 1, name: "Seishi Yokomizo" },
          { id: 2, name: "Yael Van Der Wouden" }
        ]

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data.size).to eq(2)
          expect(data.first['name']).to eq('Joe Abercrombie')
        end
      end

      response '401', 'unauthorized' do
        schema type: :object,
          properties: {
            error: { type: :string, description: 'Unauthorized' }
          },
          required: %w[error]

        example 'application/json', :unauthorized_example, {
          error: 'Unauthorized'
        }

        let(:X_Api_Key) { nil }
        run_test!
      end

      response '429', 'too_many_requests' do
        schema type: :object,
          properties: {
            error: { type: :string, description: 'Rate limit exceeded' }
          },
          required: %w[error]

        example 'application/json', :too_many_requests_example, {
          error: 'Rate limit exceeded'
        }

        run_test!
      end
    end
  end
end
