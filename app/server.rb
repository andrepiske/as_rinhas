# frozen_string_literal: true
require 'spyder'
require 'oj'
require 'multi_json'

require 'pry-byebug'

require_relative './db.rb'

puts "PID: #{Process.pid}"

$rinha_db = RinhaDB::DB.new
server = Spyder::Server.new('0.0.0.0', 8080)

server.router.add_route 'POST', '/clientes/:cid/transacoes' do |request, route_params|
  payload = MultiJson.load(request.read_full_body)
  customer_id = Integer(route_params[:cid])

  resp = Spyder::Response.new
  resp.add_standard_headers

  begin
    customer = $rinha_db.add_transaction(
      customer_id,
      Integer(payload['valor']),
      payload['tipo'],
      payload['descricao']
    )
  rescue RinhaDB::WouldLimitOverflow
    resp.code = 422
  rescue RinhaDB::CustomerNotFound
    resp.code = 404
  end

  resp
end

server.router.add_route 'GET', '/clientes/:cid/extrato' do |request, route_params|
  customer_id = Integer(route_params[:cid])

  tr_time = Time.now.httpdate

  resp = Spyder::Response.new
  resp.add_standard_headers

  begin
    stmt = $rinha_db.get_account_statement(customer_id)

    resp.set_header 'date', tr_time
    resp.set_header 'content-type', 'application/json'
    resp.body = MultiJson.dump({
      saldo: {
        total: stmt[:balance],
        data_extrato: tr_time,
        limite: stmt[:limit],
      },
      ultimas_transacoes: stmt[:last_10_transactions].map do |valor, tipo, descricao, realizada_em|
        {
          valor:,
          tipo:,
          descricao:,
          realizada_em: Time.at(realizada_em).strftime('%Y-%m-%dT%H:%M:%S.%6NZ')
        }
      end
    })

  rescue RinhaDB::CustomerNotFound
    resp.code = 404
  end

  resp
end

puts "listening..."
server.start
