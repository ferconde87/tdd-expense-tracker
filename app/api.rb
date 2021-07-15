require 'sinatra/base'
require 'json'
require_relative 'ledger'
require 'ox'

module ExpenseTracker
  class API < Sinatra::Base
    def initialize(ledger: Ledger.new)
      @ledger = ledger
      super()
    end

    post '/expenses' do
      if request.media_type == 'application/json'
        post_json(request)       
      elsif request.media_type == 'text/xml'
        post_xml(request)
      else
        status 422
        JSON.generate({'error' => "Not Supported Format"})
      end
    end

    get '/expenses/:date' do
      if request.media_type == 'application/json'
        JSON.generate(@ledger.expenses_on(params[:date]))
      elsif request.media_type == 'text/xml'
        Ox.dump(@ledger.expenses_on(params[:date]))
      else
        status 422
        JSON.generate({'error' => "Not Supported Format"})
      end
    end

    private

    def post_json(request)
      expense = JSON.parse(request.body.read)
      result = @ledger.record(expense)
      if result.success?
        JSON.generate('expense_id' => result.expense_id)
      else
        status 422
        JSON.generate('error' => result.error_message)
      end
    end

    def post_xml(request)
      expense = Ox.parse_obj(request.body.read)
      result = @ledger.record(expense)
      if result.success?
        Ox.dump('expense_id' => result.expense_id)
      else
        status 422
        Ox.dump('error' => result.error_message)
      end
    end
  end
end
  