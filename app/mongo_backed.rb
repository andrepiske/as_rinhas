# frozen_string_literal: true
require 'mongo'

module RinhaDB
  class MongoBackedDB
    attr_reader :transactions
    attr_reader :customers

    def initialize
      # @client = Mongo::Client.new(['127.0.0.1:27017'], database: 'rinha')

      @client = Mongo::Client.new(['db:27017'], database: 'rinha')
      @db = @client.database

      if ENV['DB_RESET'] == '1'
        @db[:customers].drop

        (1..5).to_a.zip([100000, 80000, 1000000, 10000000, 500000]) do |cid, limit|
          res = @db[:customers].insert_one({
            cid:, limit: -limit, balance: 0,
            transactions: []
          })
          puts "n = #{res.n}"
        end
      end
    end

    def add_transaction(cid, value, type, descr, tr_time=Time.now)
      balance_delta = (type == 'c' ? value : -value)

      res = @db[:customers].update_one({
        cid: { '$eq': cid },
        '$expr' => {
          '$lte' => [ '$limit', { '$sum': ['$balance', balance_delta] } ],
        }
      },
      {
        '$inc' => {
          balance: balance_delta
        },
        '$push' => {
          transactions: { value:, type:, descr:, tr_time: tr_time.to_f }
        }
      })

      return if res.n == 1

      customer = @db[:customers].find({
        cid:
      }, {
        projection: {
          transactions: false
        }
      }).first

      raise CustomerNotFound unless customer

      raise WouldLimitOverflow
    end

    def get_account_statement(cid)
      c = @db[:customers].aggregate([
        { '$match' => { cid: } },
        {
          '$project' => {
            limit: true,
            balance: true,
            last_10_transactions: {
              '$map' => {
                input: {
                  '$slice' => [ '$transactions', -10 ]
                },
                in: [
                  '$$this.value',
                  '$$this.type',
                  '$$this.descr',
                  '$$this.tr_time',
                ]
              }
            }
          }
        }
      ]).first

      raise CustomerNotFound unless c

      {
        balance: c[:balance],
        limit: c[:limit],
        last_10_transactions: c[:last_10_transactions],
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
