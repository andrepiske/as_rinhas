# frozen_string_literal: true

class RinhaDB
  class RinhaError < StandardError
  end
  class WouldLimitOverflow < RinhaError
  end
  class CustomerNotFound < RinhaError
  end

  attr_reader :transactions
  attr_reader :customers

  def initialize
    @customers = (1..5).to_a.zip([100000, 80000, 1000000, 10000000, 500000]).to_h do |cid, limit|
      [cid, { limit:, balance: 0 }]
    end

    @transactions = []
  end

  def add_transaction(cid, value, type, descr)
    customer = get_customer(cid)
    new_balance = customer[:balance] + (type == 'c' ? value : -value)
    if new_balance < -customer[:limit]
      raise WouldLimitOverflow
    end

    @transactions << [cid, value, type, descr]
    customer[:balance] = new_balance

    customer
  end

  def get_customer(cid)
    c = @customers[cid]
    raise CustomerNotFound unless c
    c
  end

  # def client_list
  # end
end
