require_relative '../../app/api'
require 'rack/test'
require 'json'

module ExpenseTracker
  RSpec.describe API do
    include Rack::Test::Methods

    def app
      API.new(ledger: ledger)
    end

    let(:ledger) { instance_double('ExpenseTracker::Ledger') }

    
    describe 'POST /expenses' do
      def parse_and_test(json_object, response)
        parsed = JSON.parse(json_object)
        expect(parsed).to include(response)
      end
      
      context 'when the expense is successfully recorded' do
        let(:expense) { { 'some' => 'data' } }
  
        before do
          allow(ledger).to receive(:record)
            .with(expense)
            .and_return(RecordResult.new(true, 417, nil))
        end

        it 'returns the expense id' do
          header 'Content-Type', 'application/json'
          post '/expenses', JSON.generate(expense)
          parse_and_test(last_response.body, 'expense_id' => 417)
        end

        it 'responds with a 200 (OK)' do
          header 'Content-Type', 'application/json'
          post '/expenses', JSON.generate(expense)
          expect(last_response.status).to eq(200)
        end
      end
      
      context 'when the expense is fails validation' do
        let(:expense) { { 'some' => 'data' } }
  
        before do
          allow(ledger).to receive(:record)
            .with(expense)
            .and_return(RecordResult.new(false, 417, 'Expense incomplete'))
        end

        it 'returns an error message' do
          header 'Content-Type', 'application/json'
          post '/expenses', JSON.generate(expense)
          parse_and_test(last_response.body, 'error' => 'Expense incomplete')
        end

        it 'responds with a 422 (Unprocessable entity)' do
          header 'Content-Type', 'application/json'
          post '/expenses', JSON.generate(expense)
          expect(last_response.status).to eq(422)
        end
      end
    end

    describe 'GET /expenses/:date' do
      context 'when expenses exist on the given date' do
        let(:date) { '2017-06-10' }
  
        before do
          allow(ledger).to receive(:expenses_on)
            .with(date)
            .and_return(['expense_1', 'expense_2'])
        end

        it 'returns the expense records as JSON' do
          header 'Content-Type', 'application/json'
          get "/expenses/#{date}"
          parsed = JSON.parse(last_response.body)
          expect(parsed).to eq(['expense_1', 'expense_2'])
        end
        
        it 'responds with a 200 (OK)' do
          header 'Content-Type', 'application/json'
          get "/expenses/#{date}"
          expect(last_response.status).to eq(200)
        end
      end
      
      context 'when there are no expenses on the given date' do
        let(:date) { '2021-07-13' }

        before do
          allow(ledger).to receive(:expenses_on)
            .with(date)
            .and_return([])
        end

        it 'returns an empty array as JSON' do
          header 'Content-Type', 'application/json'
          get "/expenses/#{date}"
          parsed = JSON.parse(last_response.body)
          expect(parsed).to eq([])
        end
        
        it 'responds with a 200 (OK)' do
          header 'Content-Type', 'application/json'
          get "/expenses/#{date}"
          expect(last_response.status).to eq(200)
        end
      end
    end
  end
end
  