require_relative '../config/sequel'

module ExpenseTracker
  RecordResult = Struct.new(:success?, :expense_id, :error_message)

  class Ledger
    def record(expense)
      unless expense.key?('payee')
        return invalid_expense('payee')
      end

      unless expense.key?('amount')
        return invalid_expense('amount')
      end

      unless expense.key?('date')
        return invalid_expense('date')
      end

      DB[:expenses].insert(expense)
      id = DB[:expenses].max(:id)
      RecordResult.new(true, id, nil)
    end

    def expenses_on(date)
      DB[:expenses].where(date: date).all
    end

    private 

    def invalid_expense(key)
      error_message = "Invalid expense: `#{key}` is required"
      return RecordResult.new(false, nil, error_message)
    end
  end
end
