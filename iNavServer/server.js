var express = require("express");
var app = express();
var http = require("http");
var server = http.createServer(app);
var io = require("socket.io").listen(server);
var path = require('path');
var database = {};

server.listen(3000);
app.use(express.static(path.join(__dirname, 'public')))
app.get('/', function(req, res){
  res.sendFile('public/index.html', { root : __dirname })
})

io.sockets.on("connection", function(socket) {
  setInterval(function(){ socket.emit("planesLocation", database); }, 1500);
  
  //send to everyone -> io.sockets.emit('planes',plane);
  //send to everyone except for sender -> socket.broadcast.emit('planes',plane); 
  
  // socket.id
  // socket.username
  // socket.roomnum
  
  socket.on("planeLocation", function(plane) {
    database[socket.id] = {lat:plane.lat,lng:plane.lng};
  });
  socket.on("disconnect", function() {
    //remove plane from database
    delete database[socket.id];
  });
});
