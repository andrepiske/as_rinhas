import http from 'k6/http';

export default function () {
  // const payload = JSON.stringify({
  // });

  const cid = Math.floor(Math.random() * 5) + 1;
  http.get(`http://lb:9999/clientes/${cid}/extrato`);
}
