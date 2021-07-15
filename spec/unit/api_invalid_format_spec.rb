require_relative '../../app/api'
require 'rack/test'
require 'json'
require 'ox'

module ExpenseTracker
  RSpec.describe API do
    include Rack::Test::Methods

    def app
      API.new(ledger: ledger)
    end

    let(:ledger) { instance_double('ExpenseTracker::Ledger') }
    
    describe 'POST /expenses with not supported format Context-Type' do
      let(:expense) { {'some' => 'data'} }
      it 'returns an error message' do
        header 'Content-Type', 'Not Supported'
        post '/expenses', expense
        parsed = JSON.parse(last_response.body)
        expect(parsed).to include({'error' => "Not Supported Format"})
      end

      it 'responds with a 422 (Unprocessable entity)' do
        header 'Content-Type', 'Not Supported'
        post '/expenses', expense
        expect(last_response.status).to eq(422)
      end
    end
      
    describe 'GET /expenses/:date' do
      let(:date) { '2017-06-10' }

      it 'returns an error message' do
        header 'Accept', 'Not Supported'
        get "/expenses/#{date}"
        parsed = JSON.parse(last_response.body)
        expect(parsed).to eq({'error' => "Not Supported Format"})
      end
      
      it 'responds with a 200 (OK)' do
        get "/expenses/#{date}"
        expect(last_response.status).to eq(422)
      end
    end
  end
end
  