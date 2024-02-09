# frozen_string_literal: true
require 'spyder'
require 'oj'
require 'multi_json'

require 'pry-byebug'

require_relative './db.rb'

$rinha_db = RinhaDB.new
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

puts "Now navigate to http://localhost:8080/?world=Mars"
server.start
