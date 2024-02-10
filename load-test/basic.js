import http from 'k6/http';

export default function () {
  const tipo = (Math.random() < 0.4 ? 'c' : 'd')
  const valor = Math.ceil(Math.random() * 100000);

  const payload = JSON.stringify({
    valor,
    tipo,
    descricao: 'caixa'
  });

  const cid = Math.floor(Math.random() * 5) + 1;

  const headers = { 'Content-Type': 'application/json' };
  http.post(`http://localhost:8080/clientes/${cid}/transacoes`, payload, { headers });
}
