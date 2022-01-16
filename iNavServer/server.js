var express = require("express");
var app = express();
var http = require("http");
var server = http.createServer(app);
var webSocket = require('ws');
var database = {};
var wss = new webSocket.Server({ server });

app.get('/', function(req, res){
  res.sendFile('index.html', { root : __dirname })
})

wss.on('connection', function connection(ws) {
  ws.isAlive = true;

  ws.on('pong', () => {
    ws.isAlive = true;
  });

  ws.on('message', function message(data) {
    const plane = JSON.parse(data.toString());
    ws.id = plane.id
    database[plane.id] = { id: plane.id, lat : plane.lat, lng : plane.lng };
  });
});
      
setInterval( function() { 
  wss.clients.forEach(function each(client) {
    var planes = Object.keys(database).map(key => database[key]);
    client.send(JSON.stringify(planes));
  });
}, 2000);

setInterval( function() { 
  wss.clients.forEach(function each(ws) {
    if (ws.isAlive == false) {
      delete database[ws.id]
      ws.terminate();
    } else {
      ws.isAlive = false;
      ws.ping();  
    }
  });
}, 30000);

server.listen(8080);