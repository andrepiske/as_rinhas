# frozen_string_literal: true

module RinhaDB
  class MemoryDB
    attr_reader :transactions
    attr_reader :customers

    def initialize
      @customers = (1..5).to_a.zip([100000, 80000, 1000000, 10000000, 500000]).to_h do |cid, limit|
        [cid, { limit:, balance: 0 }]
      end

      @transactions = []
    end

    def add_transaction(cid, value, type, descr, tr_time=Time.now)
      customer = get_customer(cid)
      new_balance = customer[:balance] + (type == 'c' ? value : -value)
      if new_balance < -customer[:limit]
        raise WouldLimitOverflow
      end

      # $iter += 1
      # puts "Add transaction: #{[cid, value, type, descr, tr_time.to_i]}"
      # puts "iter #{$iter}"

      @transactions << [cid, value, type, descr, tr_time.to_i]
      customer[:balance] = new_balance

      customer
    end

    def get_account_statement(cid)
      customer = get_customer(cid)

      {
        balance: customer[:balance],
        limit: customer[:limit],
        last_10_transactions: @transactions.select { |x| x[0] == cid }[...10],
      }
    end

    def get_customer(cid)
      c = @customers[cid]
      raise CustomerNotFound unless c
      c
    end

    # def client_list
    # end
  end
end
